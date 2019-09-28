//+------------------------------------------------------------------+
//|                                            Bollinger_inverse.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
extern BasePeriod = 30;
CheckForOpen(){
  
}
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   UpBand = iBands(NULL,PERIOD_CURRENT,BasPeriod,deviation,0,PRICE_CLOSE,1,1);
   DownBand = iBands(NULL,PERIOD_CURRENT,Base_iMA_Period,deviation,0,PRICE_CLOSE,2,1);
   
   
  }
//+------------------------------------------------------------------+
