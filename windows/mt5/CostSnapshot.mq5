//+------------------------------------------------------------------+
//| CostSnapshot.mq5 - READ-ONLY: samples spreads for 60 s and dumps  |
//| the cost specification of the 7 USD majors + gold to a CSV in    |
//| MQL5/Files. Places no orders. (fxplat broker study, 2026-10-18)  |
//+------------------------------------------------------------------+
#property script_show_inputs
#property strict

input int SampleSeconds = 60;

string Wanted[] = {"EURUSD","GBPUSD","USDJPY","USDCHF","USDCAD","AUDUSD","NZDUSD","XAUUSD"};

bool IsWanted(const string name, string &base)
  {
   for(int i=0;i<ArraySize(Wanted);i++)
     {
      if(StringFind(name, Wanted[i])==0)
        {
         // accept suffixed names (EURUSDm) but not XAUUSD247 or other products
         string rest = StringSubstr(name, StringLen(Wanted[i]));
         if(rest=="" || rest=="m" || rest=="c" || rest=="z" || rest==".") { base=Wanted[i]; return true; }
        }
     }
   return false;
  }

void OnStart()
  {
   string names[]; int n=0;
   int total=SymbolsTotal(false);
   for(int i=0;i<total;i++)
     {
      string s=SymbolName(i,false), b;
      if(IsWanted(s,b)) { ArrayResize(names,n+1); names[n++]=s; SymbolSelect(s,true); }
     }
   if(n==0) { Print("CostSnapshot: none of the wanted symbols found"); return; }

   double sum[], mx[]; int cnt[];
   ArrayResize(sum,n); ArrayResize(mx,n); ArrayResize(cnt,n);
   ArrayInitialize(sum,0); ArrayInitialize(mx,0); ArrayInitialize(cnt,0);
   for(int t=0;t<SampleSeconds && !IsStopped();t++)
     {
      for(int k=0;k<n;k++)
        {
         MqlTick tk;
         if(SymbolInfoTick(names[k],tk) && tk.ask>0 && tk.bid>0)
           {
            double sp=(tk.ask-tk.bid)/SymbolInfoDouble(names[k],SYMBOL_POINT);
            sum[k]+=sp; cnt[k]++; if(sp>mx[k]) mx[k]=sp;
           }
        }
      Sleep(1000);
     }

   string fn="cost_snapshot_"+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+".csv";
   int h=FileOpen(fn, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
   if(h==INVALID_HANDLE) { Print("CostSnapshot: cannot open ",fn); return; }
   FileWrite(h,"time_utc","login","server","account_mode","symbol","bid","ask","digits","point",
             "spread_avg_points","spread_max_points","samples","contract_size","volume_min","volume_step",
             "tick_value","tick_size","swap_mode","swap_long","swap_short","swap_3days","stops_level",
             "margin_initial","calc_mode","trade_mode","leverage");
   for(int k=0;k<n;k++)
     {
      string s=names[k];
      FileWrite(h, TimeToString(TimeGMT(),TIME_DATE|TIME_SECONDS),
                AccountInfoInteger(ACCOUNT_LOGIN), AccountInfoString(ACCOUNT_SERVER),
                AccountInfoInteger(ACCOUNT_TRADE_MODE), s,
                SymbolInfoDouble(s,SYMBOL_BID), SymbolInfoDouble(s,SYMBOL_ASK),
                SymbolInfoInteger(s,SYMBOL_DIGITS), SymbolInfoDouble(s,SYMBOL_POINT),
                cnt[k]>0 ? sum[k]/cnt[k] : -1, mx[k], cnt[k],
                SymbolInfoDouble(s,SYMBOL_TRADE_CONTRACT_SIZE),
                SymbolInfoDouble(s,SYMBOL_VOLUME_MIN), SymbolInfoDouble(s,SYMBOL_VOLUME_STEP),
                SymbolInfoDouble(s,SYMBOL_TRADE_TICK_VALUE), SymbolInfoDouble(s,SYMBOL_TRADE_TICK_SIZE),
                SymbolInfoInteger(s,SYMBOL_SWAP_MODE),
                SymbolInfoDouble(s,SYMBOL_SWAP_LONG), SymbolInfoDouble(s,SYMBOL_SWAP_SHORT),
                SymbolInfoInteger(s,SYMBOL_SWAP_ROLLOVER3DAYS),
                SymbolInfoInteger(s,SYMBOL_TRADE_STOPS_LEVEL),
                SymbolInfoDouble(s,SYMBOL_MARGIN_INITIAL),
                SymbolInfoInteger(s,SYMBOL_TRADE_CALC_MODE), SymbolInfoInteger(s,SYMBOL_TRADE_MODE),
                AccountInfoInteger(ACCOUNT_LEVERAGE));
     }
   FileClose(h);
   Print("CostSnapshot: wrote ",n," symbols to MQL5\\Files\\",fn);
  }
