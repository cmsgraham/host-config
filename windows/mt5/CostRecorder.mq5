//+------------------------------------------------------------------+
//| CostRecorder.mq5 - READ-ONLY service (fxplat broker study,        |
//| 2026-10-18). Samples bid/ask once a second for the 7 USD majors   |
//| and gold, and at each closed UTC hour appends one line per symbol |
//| to MQL5\Files\cost_recorder_<login>.csv: samples, spread in pips  |
//| (min / median / mean / p90 / max) and the symbol's swap settings. |
//| It never sends, modifies or closes an order.                      |
//+------------------------------------------------------------------+
#property service
#property strict

string Wanted[] = {"EURUSD","GBPUSD","USDJPY","USDCHF","USDCAD","AUDUSD","NZDUSD","XAUUSD"};

string Syms[];        // resolved symbol names on this account (EURUSD / EURUSDm / ...)
double Buf[];         // per symbol: up to 3700 spread samples (pips) for the current hour
int    Cnt[];
const int CAP = 3700;

string Resolve(const string base)
  {
   if(SymbolSelect(base, true)) return base;
   string sfx[] = {"m","c","z"};
   for(int i=0;i<ArraySize(sfx);i++)
      if(SymbolSelect(base+sfx[i], true)) return base+sfx[i];
   return "";
  }

double PipOf(const string s)
  {
   if(StringFind(s, "XAU")==0) return 0.1;                 // gold: 0.10 USD
   int d=(int)SymbolInfoInteger(s, SYMBOL_DIGITS);
   double pt=SymbolInfoDouble(s, SYMBOL_POINT);
   return (d==3 || d==5) ? pt*10.0 : pt;
  }

void Flush(datetime hour_start)
  {
   string fn = "cost_recorder_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + ".csv";
   bool fresh = !FileIsExist(fn);
   int h = FileOpen(fn, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ, ',');
   if(h==INVALID_HANDLE) { Print("CostRecorder: cannot open ", fn, " err ", GetLastError()); return; }
   FileSeek(h, 0, SEEK_END);
   if(fresh)
      FileWrite(h, "hour_utc","server","symbol","samples","spread_min","spread_median","spread_mean",
                "spread_p90","spread_max","swap_mode","swap_long","swap_short","swap_3day","contract_size");
   int n=ArraySize(Syms);
   for(int k=0;k<n;k++)
     {
      int c=Cnt[k];
      double tmp[]; ArrayResize(tmp, c);
      double sum=0;
      for(int i=0;i<c;i++) { tmp[i]=Buf[k*CAP+i]; sum+=tmp[i]; }
      if(c>0) ArraySort(tmp);
      string s=Syms[k];
      FileWrite(h, TimeToString(hour_start, TIME_DATE|TIME_MINUTES), AccountInfoString(ACCOUNT_SERVER), s, c,
                c>0 ? DoubleToString(tmp[0],3) : "",
                c>0 ? DoubleToString(tmp[c/2],3) : "",
                c>0 ? DoubleToString(sum/c,3) : "",
                c>0 ? DoubleToString(tmp[(int)MathMin(c-1, MathFloor(0.9*c))],3) : "",
                c>0 ? DoubleToString(tmp[c-1],3) : "",
                SymbolInfoInteger(s, SYMBOL_SWAP_MODE),
                SymbolInfoDouble(s, SYMBOL_SWAP_LONG), SymbolInfoDouble(s, SYMBOL_SWAP_SHORT),
                SymbolInfoInteger(s, SYMBOL_SWAP_ROLLOVER3DAYS),
                SymbolInfoDouble(s, SYMBOL_TRADE_CONTRACT_SIZE));
      Cnt[k]=0;
     }
   FileClose(h);
  }

void OnStart()
  {
   int n=0;
   for(int i=0;i<ArraySize(Wanted);i++)
     {
      string s=Resolve(Wanted[i]);
      if(s!="") { ArrayResize(Syms, n+1); Syms[n++]=s; }
      else Print("CostRecorder: symbol not available: ", Wanted[i]);
     }
   ArrayResize(Buf, n*CAP); ArrayResize(Cnt, n); ArrayInitialize(Cnt, 0);
   Print("CostRecorder: recording ", n, " symbols on ", AccountInfoString(ACCOUNT_SERVER));

   datetime cur_hour = TimeGMT() - (TimeGMT() % 3600);
   while(!IsStopped())
     {
      datetime now = TimeGMT();
      datetime hr  = now - (now % 3600);
      if(hr != cur_hour) { Flush(cur_hour); cur_hour = hr; }
      for(int k=0;k<n;k++)
        {
         MqlTick t;
         if(SymbolInfoTick(Syms[k], t) && t.bid>0 && t.ask>0 && Cnt[k]<CAP
            && (TimeCurrent()-t.time) < 60)                    // skip stale quotes (market closed)
           {
            Buf[k*CAP+Cnt[k]] = (t.ask - t.bid) / PipOf(Syms[k]);
            Cnt[k]++;
           }
        }
      Sleep(1000);
     }
   Flush(cur_hour);
   Print("CostRecorder: stopped");
  }
