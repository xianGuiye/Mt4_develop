//+------------------------------------------------------------------+
//|                                                 M1_Bollinger.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define MAGICMA  20131118
extern double deviation = 3.0;
extern int Losscut = 200;
extern double Lots = 1.0;
extern int Base_iMA_Period = 120;
extern int Short_iMA_Period = 5;
extern double limit = 0.05;
double Up_Bands,Down_Bands,Base_iMA1,Base_iMA2,Base_iMA120,Short_iMA1,Short_iMA2;


int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//--- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }
void CheckForOpen(){
   int res;

   
   //if(MathAbs(Base_iMA1 - Base_iMA120) >= limit) return;
   
   if(Short_iMA2 <= Down_Bands && Short_iMA1 > Down_Bands){
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,Black);
      return;
   }
   
   if(Short_iMA2 >= Up_Bands && Short_iMA1 < Up_Bands){
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,Black);
      return;
   }
}
void CheckForClose(){
   if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES)==false) return;
   if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) return;
   
   
   if(OrderType() == OP_BUY){
      if((Short_iMA2 <= Base_iMA2 && Short_iMA1 > Base_iMA1) || OrderProfit() <= - Losscut){
         if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Black))  Print("OrderClose error ",GetLastError());
         return;
      }
   }

   if(OrderType() == OP_SELL){
      if((Short_iMA2 >= Base_iMA2 && Short_iMA1 < Base_iMA1) || OrderProfit() <= - Losscut){
         if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Black))  Print("OrderClose error ",GetLastError());
         return;
      }
   }
   
   return;
}
void OnTick()
  {
//---

      if(Bars<100 || IsTradeAllowed()==false || Volume[0]>1)
     {
      return;
     }

   RefreshRates();
   
   Up_Bands = iBands(NULL,PERIOD_CURRENT,Base_iMA_Period,deviation,0,PRICE_CLOSE,1,1);
   Down_Bands = iBands(NULL,PERIOD_CURRENT,Base_iMA_Period,deviation,0,PRICE_CLOSE,2,1);
   Base_iMA1 = iMA(NULL,PERIOD_CURRENT,Base_iMA_Period,0,MODE_SMA,PRICE_CLOSE,1);
   Base_iMA2 = iMA(NULL,PERIOD_CURRENT,Base_iMA_Period,0,MODE_SMA,PRICE_CLOSE,2);
   Base_iMA120 = iMA(NULL,PERIOD_CURRENT,Base_iMA_Period,0,MODE_SMA,PRICE_CLOSE,120);
   Short_iMA1 = iMA(NULL,PERIOD_CURRENT,Short_iMA_Period,0,MODE_SMA,PRICE_CLOSE,1);
   Short_iMA2 = iMA(NULL,PERIOD_CURRENT,Short_iMA_Period,0,MODE_SMA,PRICE_CLOSE,2);
   
   
      if(CalculateCurrentOrders(Symbol())==0){
   
      CheckForOpen();


   }else{
      CheckForClose();
      if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
     
   }
   
   return;
  }
//+------------------------------------------------------------------+
