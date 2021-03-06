//+------------------------------------------------------------------+
//|                                                   IFD_sample.mq4 |
//|                                       Copyright 2018, xianGuiye. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, xianGuiye."
#property version   "1.00"
#property strict
#include "../include/myini.mqh"

//変数の宣言
extern bool Start_Program = false;
extern int Magic = 9696;
extern double Lots = 0.1;
extern int TP = 100;
extern int SL = 100;
extern int Interval = 50;
extern int Slippage = 10;
extern int ShortPeriod = 144;
extern int LongPeriod = 1440;
extern double TP_coefficient = 1;
extern double SL_coefficient = 1;
extern int ago = 10;
extern string Comments = "Repeat Order";

//extern int Short_coefficient = 1;
//extern int Long_coefficient = 1;
extern double Interval_coefficient = 1;
extern int ATR_PERIOD = 14;

double Short_iMA1,Long_iMA1,Short_iMA10,Long_iMA10;
double Pips = 0;
int Ticket = 0;
int Adjusted_Slippage = 0;
int Trend = 0;
int inv_Trend = 0;
double atr = 0;

//関数の定義
/*
bool JudgeTrend(){

   Short_iMA1 = iMA(NULL,PERIOD_M1,ShortPeriod,0,MODE_SMA,PRICE_CLOSE,1);
   Long_iMA1  = iMA(NULL,PERIOD_M1,LongPeriod,0,MODE_SMA,PRICE_CLOSE,1);
   Short_iMA10 = iMA(NULL,PERIOD_M1,ShortPeriod,0,MODE_SMA,PRICE_CLOSE,10);
   Long_iMA10  = iMA(NULL,PERIOD_M1,LongPeriod,0,MODE_SMA,PRICE_CLOSE,ago);
   
   if(Long_iMA1 - Long_iMA10 < 0){
      if(Short_iMA1 - Short_iMA10 < 0 && Long_iMA1 - Long_iMA10 < 0){
         if(GlobalVariableGet("TREND") > 0){
            GlobalVariableSet("TREND",-2);
            return true;
         }else{
            GlobalVariableSet("TREND",-2);
            return false;
         }
      }
      
         if(GlobalVariableGet("TREND") > 0){
            GlobalVariableSet("TREND",-1);
            return true;
         }else{
            GlobalVariableSet("TREND",-1);
            return false;
         }
   }else if(Long_iMA1 - Long_iMA10 > 0){
      if(Short_iMA1 - Short_iMA10 > 0 && Long_iMA1 - Long_iMA10 > 0){
         if(GlobalVariableGet("TREND") < 0){
            GlobalVariableSet("TREND",2);
            return true;
         }else{
            GlobalVariableSet("TREND",2);
            return false;
         }
      }
      
         if(GlobalVariableGet("TREND") < 0){
            GlobalVariableSet("TREND",1);
            return true;
         }else{
            GlobalVariableSet("TREND",1);
            return false;
         }
   }
   
   return false;
}
*/
bool JudgeTrend(){

   Short_iMA1 = iMA(NULL,PERIOD_CURRENT,ShortPeriod,0,MODE_SMA,PRICE_CLOSE,1);
   Long_iMA1  = iMA(NULL,PERIOD_CURRENT,LongPeriod,0,MODE_SMA,PRICE_CLOSE,1);
   Short_iMA10 = iMA(NULL,PERIOD_CURRENT,ShortPeriod,0,MODE_SMA,PRICE_CLOSE,10);
   Long_iMA10  = iMA(NULL,PERIOD_CURRENT,LongPeriod,0,MODE_SMA,PRICE_CLOSE,10);
   
   if(Short_iMA1 < Long_iMA1){
      if(Short_iMA1 - Short_iMA10 < 0 && Long_iMA1 - Long_iMA10 < 0){
         if(GlobalVariableGet("TREND") > 0){
            GlobalVariableSet("TREND",-2);
            return true;
         }else{
            GlobalVariableSet("TREND",-2);
            return false;
         }
      }
      
         if(GlobalVariableGet("TREND") > 0){
            GlobalVariableSet("TREND",-1);
            return true;
         }else{
            GlobalVariableSet("TREND",-1);
            return false;
         }
   }else if(Short_iMA1 > Long_iMA1){
      if(Short_iMA1 - Short_iMA10 > 0 && Long_iMA1 - Long_iMA10 > 0){
         if(GlobalVariableGet("TREND") < 0){
            GlobalVariableSet("TREND",2);
            return true;
         }else{
            GlobalVariableSet("TREND",2);
            return false;
         }
      }
      
         if(GlobalVariableGet("TREND") < 0){
            GlobalVariableSet("TREND",1);
            return true;
         }else{
            GlobalVariableSet("TREND",1);
            return false;
         }
   }
   
   return false;
}

void All_Close(){
   

   if(GlobalVariableGet("Trend") >= 1){
   for(int i = OrdersTotal() - 1;i >= 0; i--){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(!OrderClose(OrderTicket(),OrderLots(),Bid,Adjusted_Slippage,Aqua)) continue;
   }
   }else{
   for(int i = OrdersTotal() - 1;i >= 0; i--){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(!OrderClose(OrderTicket(),OrderLots(),Ask,Adjusted_Slippage,Pink)) continue;
   }
   }
   
   
}
int init()
{
  Pips = AdjustPoint(Symbol());
  Adjusted_Slippage =
  AdjustSlippage(Symbol(),Slippage);
  
  return(0);
}
int start(){

   if(Volume[0] <= 1){
      atr = iATR(NULL,PERIOD_H1,ATR_PERIOD,1);
      if(Pips == 0.01){
         NormalizeDouble(atr,3);
      }
   }
   
   if(JudgeTrend() && Volume[0] <= 1){
      All_Close();
   }
  
   
   Trend = GlobalVariableGet("TREND");
   
   if(Trend >= 1){
      if(OrdersTotal() == 0){
         Ticket = OrderSend(Symbol(),OP_BUY,Trend*Lots,Ask,Adjusted_Slippage,0,0,Comments,Magic,0,Magenta);
         
         if(Ticket > 0){
            if(OrderSelect(Ticket,SELECT_BY_TICKET) == true){
               bool Modified = OrderModify(OrderTicket(),OrderOpenPrice(),
                                             OrderOpenPrice() - SL * Pips,//atr * SL_coefficient ,//////- 
                                             OrderOpenPrice() + TP * Pips,//atr * TP_coefficient ,//////
                                             OrderExpiration(),clrNONE);
                                            
               if(Modified == true){
                  Ticket = 0;
               }
            }
         }
       }else if(OrdersTotal() >= 1){
            if(OrderSelect(OrdersTotal() - 1,SELECT_BY_POS,MODE_TRADES) == true){
               if(Bid <= OrderOpenPrice() - Interval * Pips){
                  Ticket = OrderSend(Symbol(),OP_BUY,Trend*Lots,Ask,Adjusted_Slippage,0,0,Comments,Magic,0,Magenta);
                  
                  if(Ticket > 0){
                     if(OrderSelect(Ticket,SELECT_BY_TICKET) == true){
                        bool Modified = OrderModify(OrderTicket(),OrderOpenPrice(),
                                                   OrderOpenPrice() - SL * Pips / Trend,//atr * SL_coefficient,//SL * Pips / Trend,////
                                                   OrderOpenPrice() + TP * Pips,//atr * TP_coefficient,//////
                                                   OrderExpiration(),clrNONE);
                                                   
                        if(Modified == true){
                           Ticket = 0;
                        }
                     }
                  }
               }
            }
         }
      }else if(Trend <= -1){
         inv_Trend = MathAbs(Trend);
      
            if(OrdersTotal() == 0){
         Ticket = OrderSend(Symbol(),OP_SELL,inv_Trend*Lots,Bid,Adjusted_Slippage,0,0,Comments,Magic,0,Magenta);
         
         if(Ticket > 0){
            if(OrderSelect(Ticket,SELECT_BY_TICKET) == true){
               bool Modified = OrderModify(OrderTicket(),OrderOpenPrice(),
                                             OrderOpenPrice() + SL * Pips / inv_Trend,//atr * SL_coefficient,// ////SL * Pips / inv_Trend,
                                             OrderOpenPrice() - TP * Pips,//atr * TP_coefficient,//////
                                             OrderExpiration(),clrNONE);
                                             
               if(Modified == true){
                  Ticket = 0;
               }
            }
         }
       }else if(OrdersTotal() >= 1){
            if(OrderSelect(OrdersTotal() - 1,SELECT_BY_POS,MODE_TRADES) == true){
               if(Ask >= OrderOpenPrice() + Interval * Pips){
                  Ticket = OrderSend(Symbol(),OP_SELL,inv_Trend*Lots,Bid,Adjusted_Slippage,0,0,Comments,Magic,0,Magenta);
                  
                  if(Ticket > 0){
                     if(OrderSelect(Ticket,SELECT_BY_TICKET) == true){
                        bool Modified = OrderModify(OrderTicket(),OrderOpenPrice(),
                                                   OrderOpenPrice() + SL * Pips / inv_Trend,//atr * SL_coefficient,//////
                                                   OrderOpenPrice() - TP * Pips,//atr * TP_coefficient,//////TP * Pips,
                                                   OrderExpiration(),clrNONE);
                                                   
                        if(Modified == true){
                           Ticket = 0;
                        }
                     }
                  }
               }
            }
         }
      }
      return 0;
     
}