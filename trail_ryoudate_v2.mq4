﻿//+------------------------------------------------------------------+
//|                                            trail_ryoudate_v2.mq4 |
//|                                       Copyright 2018, xianGuiye. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, xianGuiye."
#property version   "1.00"
#property strict
#include "../include/myini.mqh"

extern bool Start_Program = false;
extern int Magic = 2525;
extern double Lots = 0.01;
extern int Trailing_Stop = 5;
extern int Slippage = 10;
extern int ShortOrLong = 0;
extern string Comments = "trail order";


int Ticket = 0;
int buys = 0;
int sells = 0;
double Pips = 0;
int Adjusted_Slippage = 0;
int interval = 100;
int tp = 100;


int init()
{
  Pips = AdjustPoint(Symbol());
  Adjusted_Slippage =
  AdjustSlippage(Symbol(),Slippage);
       
  return(0);
}
void InitPosition(){
　　　　int i=0;
      
   //for(i = OrdersHistoryTotal() - 1;i >= 0;i --){
   //   if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) == true){
   //      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic){
   //         break;
   //      }
   //   }
   //}
   
   //if(OrderType() == OP_BUY){
   //   Ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,Adjusted_Slippage,Ask + Trailing_Stop * Pips,0,Comments,Magic,0,Blue);
   //}else if(OrderType() == OP_SELL){
   //   Ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,Adjusted_Slippage,Bid - Trailing_Stop * Pips,0,Comments,Magic,0,White);
   //}else{
   //   if(ShortOrLong == 1){
   //      Ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,Adjusted_Slippage,Bid - Trailing_Stop * Pips,0,Comments,Magic,0,White);
   //   }else if(ShortOrLong == -1){
   //      Ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,Adjusted_Slippage,Ask + Trailing_Stop * Pips,0,Comments,Magic,0,Blue);
   //   }
   //}
   OrderSend(Symbol(),OP_BUY,Lots,Ask,Adjusted_Slippage,0,0,Comments,Magic,0,White);
   OrderSend(Symbol(),OP_SELL,Lots,Bid,Adjusted_Slippage,0,0,Comments,Magic,0,Blue);
   
}

void OrderEdit(){
   int i=0;
   
      double spread = MarketInfo(Symbol(),MODE_SPREAD);  
      double LongNewStopLoss = Bid - Trailing_Stop * Pips;
      double ShortNewStopLoss = Ask + Trailing_Stop * Pips;
   
         for(i = OrdersTotal() - 1;i >= 0;i --){
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true && OrderType() == OP_BUY){
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic){
                  break;
               }
            }
         }
                 if(Bid > OrderOpenPrice() + Trailing_Stop * Pips || OrderStopLoss() != 0){
                        if(OrderStopLoss() < LongNewStopLoss){
                           bool Modified = OrderModify(OrderTicket(),OrderOpenPrice(),LongNewStopLoss,0,OrderExpiration(),clrNONE);
                           OrderSend(Symbol(),OP_BUY,Lots,LongNewStopLoss,Adjusted_Slippage,0,0,Comments,Magic,0,Green);
                           OrderSend(Symbol(),OP_SELL,Lots,LongNewStopLoss-Pips*spread/10,Adjusted_Slippage,0,0,Comments,Magic,0,Red);    
                        }
                }
                  
                     
         for(i = OrdersTotal() - 1;i >= 0;i --){
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true && OrderType() == OP_SELL){
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic){
                  break;
               }
            }
         }
                  
                 if(Ask < OrderOpenPrice() + Trailing_Stop * Pips || OrderStopLoss() != 0){
                        if(OrderStopLoss() > ShortNewStopLoss){
                           bool Modified = OrderModify(OrderTicket(),OrderOpenPrice(),ShortNewStopLoss,0,OrderExpiration(),clrNONE);
                           OrderSend(Symbol(),OP_BUY,Lots,LongNewStopLoss,Adjusted_Slippage,0,0,Comments,Magic,0,Green);
                           OrderSend(Symbol(),OP_SELL,Lots,LongNewStopLoss-Pips*spread/10,Adjusted_Slippage,0,0,Comments,Magic,0,Red);    
                        }
                }
              
}

int start(){
   int i=0;
   
   
    
   
   CalculateCurrentOrders(Symbol());

      
      if(buys == 0 && sells == 0){
         InitPosition();
      }else{
      
      OrderEdit();
   
      }
      
      return(0);
 }
