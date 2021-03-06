//+------------------------------------------------------------------+
//|                                               M5_M30integral.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define MAGICMA  20131116
double M5_Middle_iMA1,M5_Short_iMA1,M5_Middle_iMA2,M5_Short_iMA2,M5_Middle_iMA10,M5_Short_iMA10,M30_Middle_iMA10,M30_Short_iMA10,Slope,ShortSlope;
double M30_Middle_iMA1,M30_Short_iMA1,M30_Middle_iMA2,M30_Short_iMA2,ThisTrend,M30_Long_iMA1,M30_Long_iMA10;
extern int M30_Long = 120;
extern int M30_Middle= 36;
extern int M30_Short = 4;
extern int M5_Middle = 12;
extern int M5_Short=3;
extern double LossCut=0.0003;
extern double TakeProfit=0.0006;
extern double Lots=1.0;
//--- ポジションの計算
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
//--- トレンドの判定
void WhichTrend()
  {
  
   int res;

   M30_Middle_iMA1= iMA(NULL,PERIOD_M30,M30_Middle,0,MODE_SMA,PRICE_CLOSE,1);
   M30_Short_iMA1 = iMA(NULL,PERIOD_M30,M30_Short,0,MODE_SMA,PRICE_CLOSE,1);
   M30_Middle_iMA2= iMA(NULL,PERIOD_M30,M30_Middle,0,MODE_SMA,PRICE_CLOSE,2);
   M30_Short_iMA2 = iMA(NULL,PERIOD_M30,M30_Short,0,MODE_SMA,PRICE_CLOSE,2);
   M30_Middle_iMA10= iMA(NULL,PERIOD_M30,M30_Middle,0,MODE_SMA,PRICE_CLOSE,10);
   M30_Short_iMA10 = iMA(NULL,PERIOD_M30,M30_Short,0,MODE_SMA,PRICE_CLOSE,10);
   M30_Long_iMA1 = iMA(NULL,PERIOD_M30,M30_Long,0,MODE_SMA,PRICE_CLOSE,1);
   M30_Long_iMA10 = iMA(NULL,PERIOD_M30,M30_Long,0,MODE_SMA,PRICE_CLOSE,10);

   if(M30_Middle_iMA1<M30_Short_iMA1)
     {
      if(M30_Middle_iMA2>=M30_Short_iMA2 && CalculateCurrentOrders(Symbol())==0)
        {
         GlobalVariableSet("LOSSCUT",0);
         GlobalVariableSet("TAKEPROFIT",0);
         
         if(((M30_Middle_iMA1 <= M30_Short_iMA1 && M30_Short_iMA1 <= M30_Long_iMA1) || (M30_Long_iMA1 <= M30_Short_iMA1 && M30_Short_iMA1 <= M30_Middle_iMA1)) || MathAbs(M30_Long_iMA1 - M30_Long_iMA10) <= 0.00075){
            return;
         }
         res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,Aqua);
        }

      GlobalVariableSet("THISTREND",1.0);
      return;
     }

   if(M30_Middle_iMA1>M30_Short_iMA1)
     {
      if(M30_Middle_iMA2<=M30_Short_iMA2 && CalculateCurrentOrders(Symbol())==0)
        {
         
         GlobalVariableSet("LOSSCUT",0);
         GlobalVariableSet("TAKEPROFIT",0);
         
         if(((M30_Middle_iMA1 <= M30_Short_iMA1 && M30_Short_iMA1 <= M30_Long_iMA1) || (M30_Long_iMA1 <= M30_Short_iMA1 && M30_Short_iMA1 <= M30_Middle_iMA1)) || MathAbs(M30_Long_iMA1 - M30_Long_iMA10) <= 0.00075){
            return;
         }
         res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,DeepPink);
        }
      GlobalVariableSet("THISTREND",-1.0);
      return;
     }

   GlobalVariableSet("THISTREND",0);
   return;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {

   if(Volume[0]>1 || CalculateCurrentOrders(Symbol())!=0)
     {
      return;
     }

   int res;

   if(ThisTrend==1.0)
     {
      if(M5_Middle_iMA1<M5_Short_iMA1 && M5_Middle_iMA2>=M5_Short_iMA2)
        {
         res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,Maroon);
         return;
           }else if(M5_Middle_iMA1<M5_Short_iMA1 && Open[0]-M5_Short_iMA1>=0.0004){

            CheckLastOrder();
            double LastOpen = GlobalVariableGet("LASTLOSSCUT");
            Print(LastOpen);
            if(LastOpen<Open[0]){
            res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,Maroon);
            Print("ae");
            }
            return;
           }
        }else if(ThisTrend==-1.0){
      if(M5_Middle_iMA1>M5_Short_iMA1 && M5_Middle_iMA2<=M5_Short_iMA2)
        {
         res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,Blue);
         return;
           }else if(M5_Middle_iMA1>M5_Short_iMA1 && M5_Short_iMA1-Open[0]>=0.0004 && ShortSlope<=-0.00002){
         
            CheckLastOrder();
            double LastOpen = GlobalVariableGet("LASTLOSSCUT");
               if(LastOpen>Open[0]){
               res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,Blue);
               }
            return;

        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForClose()
  {

   int res;

   if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES)==false) return;
   if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) return;





   if(OrderType()==OP_BUY)
     {
      if(Volume[0]==1)
        {
         //if(M5_Middle_iMA1 > M5_Short_iMA1 && M5_Middle_iMA2 <= M5_Short_iMA2){
         if(Close[1]<=M5_Short_iMA1 && ShortSlope<=-0.00002)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Black))
               Print("OrderClose error ",GetLastError());
            
            return;
           }

         JudgeLossCut();
           }else{

         JudgeTakeProfit();

/*if(Acquisition - Bid >= LossCut){
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Red)){
                 Print("OrderClose error ",GetLastError());
                 }
               
                 return;
         }
            if(Bid - Acquisition >= TakeProfit){
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Green))
               Print("OrderClose error ",GetLastError());
             
               if(M5_Middle_iMA1 < M5_Short_iMA1 && Slope >= 0.0005){
                  res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,White);
               }
               return;
            }
            */
        }
     }

   if(OrderType()==OP_SELL)
     {
      if(Volume[0]==1)
        {
         //if(M5_Middle_iMA1 < M5_Short_iMA1 && M5_Middle_iMA2 >= M5_Short_iMA2){
         if(Close[1]>=M5_Short_iMA1 && ShortSlope>=0.00002)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Black))
               Print("OrderClose error ",GetLastError());
            return;
           }

         JudgeLossCut();
           }else{

         JudgeTakeProfit();

/*
            if(Ask - Acquisition >= LossCut){
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Red))
                    Print("OrderClose error ",GetLastError());
               
                    return;
            }
              if(M5_Middle_iMA1 -  M5_Short_iMA1 >= TakeProfit){
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Green))
                  Print("OrderClose error ",GetLastError());
              
               if(M5_Middle_iMA1 > M5_Short_iMA1 && Slope <= 0.0005){
                  res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,Yellow);
               }
            return;
            }
            */

        }
     }

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JudgeTakeProfit()
  {
   if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES)==false) return;
   if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) return;

   double Acquisition=OrderOpenPrice();

   if(OrderType()==OP_SELL)
     {
      if(Acquisition-Ask>=TakeProfit)
        {
         GlobalVariableSet("LASTEXIT",Ask);
         if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Green))
           {
            Print("OrderClose error ",GetLastError());
           }
         GlobalVariableSet("TAKEPROFIT",-1.0);
        }

      return;
     }

   if(OrderType()==OP_BUY)
     {
      if(Bid-Acquisition>=TakeProfit)
        {
         GlobalVariableSet("LASTEXIT",Bid);
         if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Green))
           {
            Print("OrderClose error ",GetLastError());
           }
         GlobalVariableSet("TAKEPROFIT",1.0);
        }

      return;
     }

   return;



  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AfterLongTakeProfit()
  {

   int res;

   if(M5_Middle_iMA1<M5_Short_iMA1 && Slope>=0.00005 && ThisTrend==1.0)
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,White);
      GlobalVariableSet("TAKEPROFIT",0);
      return;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AfterShortTakeProfit()
  {
   int res;

   if(M5_Middle_iMA1>M5_Short_iMA1 && Slope<=-0.00005 && ThisTrend==-1.0)
     {

      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,Yellow);
      GlobalVariableSet("TAKEPROFIT",0);
      return;
     }


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void JudgeLossCut()
  {
   if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES)==false) return;
   if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) return;

   double Acquisition=OrderOpenPrice();

   if(OrderType()==OP_BUY)
     {
      if(Acquisition-Open[0]>=LossCut)
        {
         
         if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Red))
           {
            Print("OrderClose error ",GetLastError());
           }
         GlobalVariableSet("LOSSCUT",1.0);
         GlobalVariableSet("LASTEXIT",Bid);
         CheckLastOrder();
        }
      return;
     }

   if(OrderType()==OP_SELL)
     {
      if(Open[0]-Acquisition>=LossCut)
        {
         
         if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Red))
           {
            Print("OrderClose error ",GetLastError());
           }
         GlobalVariableSet("LOSSCUT",-1.0);
         GlobalVariableSet("LASTEXIT",Ask);
         CheckLastOrder();
        }
      return;
     }

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AfterLongLossCut()
  {
   int res;
  
   double L = GlobalVariableGet("LASTLOSSCUT");
   //double L = GlobalVariableGet("LASTEXIT");
   
   if(Open[0]> L && ThisTrend==1.0)
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,White);
      GlobalVariableSet("LOSSCUT",0);
      return;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AfterShortLossCut()
  {
   int res;

   double S = GlobalVariableGet("LASTLOSSCUT");
   //double S = GlobalVariableGet("LASTEXIT");

   if(Open[0]< S && ThisTrend==-1.0)
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,Yellow);
      GlobalVariableSet("LOSSCUT",0);
      return;
     }

  }
void CheckLastOrder(){
      for(int i=OrdersHistoryTotal()-1;i>=0;i--){
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false){
     
            Print("OrderClose error ",GetLastError());
            break;
         }
       
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      int Type = OrderType();

         if(Type == OP_BUY || Type == OP_SELL){
           
             GlobalVariableSet("LASTLOSSCUT",OrderOpenPrice());
             
             break;
         }
      }

      return;

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   if(Bars<100 || IsTradeAllowed()==false)
     {
      return;
     }

   RefreshRates();

   if(Time[0]%1800==0 && Volume[0]==1)
     {
      WhichTrend();
     }

   ThisTrend=GlobalVariableGet("THISTREND");

   if(Volume[0]==1)
     {
      M5_Middle_iMA1= iMA(NULL,PERIOD_M5,M5_Middle,0,MODE_SMA,PRICE_CLOSE,1);
      M5_Short_iMA1 = iMA(NULL,PERIOD_M5,M5_Short,0,MODE_SMA,PRICE_CLOSE,1);
      M5_Middle_iMA2= iMA(NULL,PERIOD_M5,M5_Middle,0,MODE_SMA,PRICE_CLOSE,2);
      M5_Short_iMA2 = iMA(NULL,PERIOD_M5,M5_Short,0,MODE_SMA,PRICE_CLOSE,2);
      M5_Middle_iMA10= iMA(NULL,PERIOD_M5,M5_Middle,0,MODE_SMA,PRICE_CLOSE,10);
      M5_Short_iMA10 =  iMA(NULL,PERIOD_M5,M5_Short,0,MODE_SMA,PRICE_CLOSE,10);
      Slope=M5_Middle_iMA1-M5_Middle_iMA10;
      ShortSlope=M5_Short_iMA1-M5_Short_iMA2;
     }
   
   if(((M30_Middle_iMA1 <= M30_Short_iMA1 && M30_Short_iMA1 <= M30_Long_iMA1) || (M30_Long_iMA1 <= M30_Short_iMA1 && M30_Short_iMA1 <= M30_Middle_iMA1)) || MathAbs(M30_Long_iMA1 - M30_Long_iMA10) <= 0.00075){
      if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES)==false) return;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) return;
      if(OrderType()==OP_SELL){
         if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Gold))
            Print("OrderClose error ",GetLastError());
            return;
         }else if(OrderType()==OP_BUY){
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Gold))
            Print("OrderClose error ",GetLastError());
            return;
         }
         
         return;
   }
   
   if(GlobalVariableGet("LOSSCUT")==0 && GlobalVariableGet("TAKEPROFIT")==0 && Volume[0]==1)
     {
      if(CalculateCurrentOrders(Symbol())==0)
        {
         
         CheckForOpen();
         return;
         }

         CheckForClose();
         return;
         }else if(GlobalVariableGet("LOSSCUT")==1.0 && Volume[0]==1){
         AfterLongLossCut();
         return;
         }else if(GlobalVariableGet("LOSSCUT")==-1.0 && Volume[0]==1){
         AfterShortLossCut();
         return;
         }else if(GlobalVariableGet("TAKEPROFIT")==1.0){
         AfterLongTakeProfit();
         return;
         }else if(GlobalVariableGet("TAKEPROFIT")==-1.0){
         AfterShortTakeProfit();
         return;
         }

         

         return;
         }
         //+------------------------------------------------------------------+
