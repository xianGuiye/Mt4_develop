//+------------------------------------------------------------------+
//|                                            Long_Middle_cross.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define MAGICMA  20131115
double ShortEA1,MiddleEA1,ShortEA2,MiddleEA2,FirstHighest,SecondHighest,FirstLowest,SecondLowest;
extern int twenty_five_days = 150;
extern int five_days = 30;
extern int Lots = 1;
extern int FirstAdd = 360;
extern int SecondAdd = 720;
extern int losslimit = 1000; 

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
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
void CheckForOpen(){ 
   int res;

   //if( ShortEA1 > MiddleEA1 ){
      if(Open[0] > ShortEA1 && Open[0] <= MiddleEA1 && OrdersTotal() == 0){
         res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,Blue);
         return;
      }
      /*
      else if(FirstHighest < ShortEA1 && OrdersTotal() == 1){
         res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,Blue);
         return;
      }else if(SecondHighest < ShortEA1 && OrdersTotal() == 2){
         res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,Blue);
         return;
      }
      */
   //}
   
   if(ShortEA1 < MiddleEA1){
      if(ShortEA2 >= MiddleEA2 && OrdersTotal() == 0){
         res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,Green);
         return;
      }
      /*
      else if(FirstLowest > ShortEA1 && OrdersTotal() == 1){
         res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,Green);
         return;
      }else if(SecondLowest > ShortEA1 && OrdersTotal() == 2){
         res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,Green);
         return;
      }
      */
   }
   
   return;
}
void CheckForClose(){

   if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES)==false) return;
   double LossProfit = OrderProfit();
   

   //if((OrderType()==OP_BUY && ShortEA2 >= MiddleEA2 && ShortEA1 < MiddleEA1) || LossProfit <= -Lots * losslimit)
   if(OrderType() == OP_BUY && Open[0] <= ShortEA1)
     {
      for(int i=OrdersTotal()-1; i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
         if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
            Print("OrderClose error ",GetLastError());
        }
     }

   if((OrderType()==OP_SELL && ShortEA2 <= MiddleEA2 && ShortEA1 > MiddleEA1) || LossProfit <= -Lots * losslimit)
     {
      for(int i=OrdersTotal()-1; i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
         if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
            Print("OrderClose error ",GetLastError());
        }
     }
     
     return;
}
void OnTick()
  {
//---
   if(Volume[0]>1) return;
   
   if(Bars<100 || IsTradeAllowed()==false)
     return;
   
   ShortEA1 = iMA(NULL,PERIOD_CURRENT,five_days,0,MODE_SMA,PRICE_CLOSE,1);
   ShortEA2 = iMA(NULL,PERIOD_CURRENT,five_days,0,MODE_SMA,PRICE_CLOSE,2);
   MiddleEA1 = iMA(NULL,PERIOD_CURRENT,twenty_five_days,0,MODE_SMA,PRICE_CLOSE,1);
   MiddleEA2 = iMA(NULL,PERIOD_CURRENT,twenty_five_days,0,MODE_SMA,PRICE_CLOSE,2);
   
   FirstHighest = iHighest(NULL,PERIOD_CURRENT,MODE_CLOSE,FirstAdd);
   SecondHighest = iHighest(NULL,PERIOD_CURRENT,MODE_CLOSE,SecondAdd);
   FirstLowest = iLowest(NULL,PERIOD_CURRENT,MODE_CLOSE,FirstAdd);
   SecondLowest = iLowest(NULL,PERIOD_CURRENT,MODE_CLOSE,SecondAdd);
   
      if(CalculateCurrentOrders(Symbol())==0){
       CheckForOpen();
      }else{
       CheckForClose();
       CheckForOpen();
      }
  }
//+------------------------------------------------------------------+
