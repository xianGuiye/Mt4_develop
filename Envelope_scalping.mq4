﻿//+------------------------------------------------------------------+
//|                                            Envelope_scalping.mq4 |
//|                                       Copyright 2019, xianGuiye. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, xianGuiye."
#property strict
#include "../include/myini.mqh"

extern double Lots = 0.1;
extern int Slippage = 10;
extern double LossCut = 3;
extern double TakeProfit = 3;

double margin1 = 1.0;
double margin2 = 1.5;
double margin3 = 2.0;
double margin4 = 2.5;
double margin5 = 3.0;
double margin6 = 3.5;
int Adjusted_Slippage = 0;
double Pips = 0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
  Pips = InitPips(Symbol());
  Adjusted_Slippage = InitSlippage(Symbol(),Slippage);
       
  return(0);
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
void Judge_Trade(){
   double SMMA = iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,0);
   double UP_Env1 = iEnvelopes(NULL,0,20,MODE_SMMA,0,PRICE_CLOSE,0.10,MODE_UPPER,0);
   double UP_Env2 = iEnvelopes(NULL,0,20,MODE_SMMA,0,PRICE_CLOSE,0.15,MODE_UPPER,0);
   double UP_Env3 = iEnvelopes(NULL,0,20,MODE_SMMA,0,PRICE_CLOSE,0.20,MODE_UPPER,0);
   double UP_Env4 = iEnvelopes(NULL,0,20,MODE_SMMA,0,PRICE_CLOSE,0.25,MODE_UPPER,0);
   double UP_Env5 = iEnvelopes(NULL,0,20,MODE_SMMA,0,PRICE_CLOSE,0.30,MODE_UPPER,0);
   double UP_Env6 = iEnvelopes(NULL,0,20,MODE_SMMA,0,PRICE_CLOSE,0.40,MODE_UPPER,0);
   double LO_Env1 = iEnvelopes(NULL,0,20,MODE_SMMA,0,PRICE_CLOSE,0.10,MODE_LOWER,0);
   double LO_Env2 = iEnvelopes(NULL,0,20,MODE_SMMA,0,PRICE_CLOSE,0.15,MODE_LOWER,0);
   double LO_Env3 = iEnvelopes(NULL,0,20,MODE_SMMA,0,PRICE_CLOSE,0.20,MODE_LOWER,0);
   double LO_Env4 = iEnvelopes(NULL,0,20,MODE_SMMA,0,PRICE_CLOSE,0.25,MODE_LOWER,0);
   double LO_Env5 = iEnvelopes(NULL,0,20,MODE_SMMA,0,PRICE_CLOSE,0.30,MODE_LOWER,0);
   double LO_Env6 = iEnvelopes(NULL,0,20,MODE_SMMA,0,PRICE_CLOSE,0.40,MODE_LOWER,0);
   bool Ticket;
   
   //ポジションを保持していないとき
   if(OrdersTotal() == 0){
   
      if((0 <= DayOfYear() && DayOfYear() < 7) || (357 < DayOfYear() && DayOfYear() <= 366)) return;
      if((15 <= Hour() && Hour() <= 19) || (22 <= Hour() && Hour() <= 24) || (0 <= Hour() && Hour() <= 4)) return; 
      OrderSelect(0,SELECT_BY_POS,MODE_HISTORY);
      for(int i=OrdersHistoryTotal()-1;i>=0;i--){
         if(OrderSymbol()==Symbol() && OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) == true){
            if(OrderMagicNumber() == 4863 || OrderMagicNumber() == 4869)break;
         }
      }
      if(long(TimeCurrent())/60 == long(OrderCloseTime())/60) return;
      if((long(OrderCloseTime()) + 3600 >= long(TimeCurrent())) && OrderProfit() < 0) return;
      if((Ask+Bid)/2 > SMMA){
         if(Open[0] < UP_Env1 && UP_Env1 < Bid){
            Ticket = OrderSend(Symbol(),OP_SELL,Lots*margin1,Bid,Adjusted_Slippage,0,0,"Up_Env1",4863,0,Magenta);
         }
         /*
         else if(Open[0] < UP_Env2 && UP_Env2 < Bid){
            Ticket = OrderSend(Symbol(),OP_SELL,Lots*margin2,Bid,Adjusted_Slippage,0,0,"Up_Env2",4864,0,Magenta);
         }
         else if(Open[0] < UP_Env3 && UP_Env3 < Bid){
            Ticket = OrderSend(Symbol(),OP_SELL,Lots*margin3,Bid,Adjusted_Slippage,0,0,"Up_Env3",4865,0,Magenta);
         }
         else if(Open[0] < UP_Env4 && UP_Env4 < Bid){
            Ticket = OrderSend(Symbol(),OP_SELL,Lots*margin4,Bid,Adjusted_Slippage,0,0,"Up_Env4",4866,0,Magenta);
         }
         else if(Open[0] < UP_Env5 && UP_Env5 < Bid){
            Ticket = OrderSend(Symbol(),OP_SELL,Lots*margin5,Bid,Adjusted_Slippage,0,0,"Up_Env5",4867,0,Magenta);
         }
         else if(Open[0] < UP_Env6 && UP_Env6 < Bid){
            Ticket = OrderSend(Symbol(),OP_SELL,Lots*margin6,Bid,Adjusted_Slippage,0,0,"Up_Env6",4868,0,Magenta);
         }
         */
      }
      else if((Ask+Bid)/2 < SMMA){
         if(Open[0] > LO_Env1 && LO_Env1 > Ask){
            Ticket = OrderSend(Symbol(),OP_BUY,Lots*margin1,Ask,Adjusted_Slippage,0,0,"Lo_Env1",4869,0,Blue);
         }
         /*
         else if(Open[0] > LO_Env2 && LO_Env2 > Ask){
            Ticket = OrderSend(Symbol(),OP_BUY,Lots*margin2,Ask,Adjusted_Slippage,0,0,"Lo_Env2",4870,0,Magenta);
         }
         else if(Open[0] > LO_Env3 && LO_Env3 > Ask){
            Ticket = OrderSend(Symbol(),OP_BUY,Lots*margin3,Ask,Adjusted_Slippage,0,0,"Lo_Env3",4871,0,Magenta);
         }
         else if(Open[0] > LO_Env4 && LO_Env4 > Ask){
            Ticket = OrderSend(Symbol(),OP_BUY,Lots*margin4,Ask,Adjusted_Slippage,0,0,"Lo_Env4",4872,0,Magenta);
         }
         else if(Open[0] > LO_Env5 && LO_Env5 > Ask){
            Ticket = OrderSend(Symbol(),OP_BUY,Lots*margin5,Ask,Adjusted_Slippage,0,0,"Lo_Env5",4873,0,Magenta);
         }
         else if(Open[0] > LO_Env6 && LO_Env6 > Ask){
            Ticket = OrderSend(Symbol(),OP_BUY,Lots*margin6,Ask,Adjusted_Slippage,0,0,"Lo_Env6",4874,0,Magenta);
         }
         */
      }
      return;
   }
   
   //ポジションを保持しているとき
   if(OrdersTotal() == 1){
      OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
      if(TimeCurrent()/60 == OrderOpenTime()/60) return;
      if(OrderType() == OP_SELL){
         if(OrderMagicNumber() == 4863 && (OrderOpenPrice() + LossCut*Pips  <= Ask || Ask <= OrderOpenPrice() - TakeProfit*Pips)){
            OrderClose(OrderTicket(),Lots*margin1,Ask,Adjusted_Slippage,Aqua);
         }
         /*
         else if(OrderMagicNumber() == 4864 && ((UP_Env2 + UP_Env3)/2 < Ask || Ask < (SMMA + UP_Env1)/2)){
            OrderClose(OrderTicket(),Lots*margin2,Ask,Adjusted_Slippage,Aqua);
         }
         else if(OrderMagicNumber() == 4865 && ((UP_Env3 + UP_Env4)/2 < Ask || Ask < (SMMA + UP_Env1)/2)){
            OrderClose(OrderTicket(),Lots*margin3,Ask,Adjusted_Slippage,Aqua);
         }
         else if(OrderMagicNumber() == 4866 && ((UP_Env4 + UP_Env5)/2 < Ask || Ask < (SMMA + UP_Env1)/2)){
            OrderClose(OrderTicket(),Lots*margin4,Ask,Adjusted_Slippage,Aqua);
         }
         else if(OrderMagicNumber() == 4867 && ((UP_Env5 + UP_Env6)/2 < Ask || Ask < (SMMA + UP_Env1)/2)){
            OrderClose(OrderTicket(),Lots*margin5,Ask,Adjusted_Slippage,Aqua);
         }
         else if(OrderMagicNumber() == 4868 && (UP_Env6 + 1.0 < Ask || Ask < (SMMA + UP_Env1)/2)){
            OrderClose(OrderTicket(),Lots*margin6,Ask,Adjusted_Slippage,Aqua);
         }
         */
      }
            if(OrderType() == OP_BUY){
         if(OrderMagicNumber() == 4869 && (OrderOpenPrice() - LossCut*Pips >= Bid || Bid >= OrderOpenPrice() + TakeProfit*Pips)){
            OrderClose(OrderTicket(),Lots*margin1,Bid,Adjusted_Slippage,Aqua);
         }
         /*
         else if(OrderMagicNumber() == 4870 && ((LO_Env2 + LO_Env3)/2 > Bid || Bid > (SMMA + LO_Env1)/2)){
            OrderClose(OrderTicket(),Lots*margin2,Bid,Adjusted_Slippage,Aqua);
         }
         else if(OrderMagicNumber() == 4871 && ((LO_Env3 + LO_Env4)/2 > Bid || Bid > (SMMA + LO_Env1)/2)){
            OrderClose(OrderTicket(),Lots*margin3,Bid,Adjusted_Slippage,Aqua);
         }
         else if(OrderMagicNumber() == 4872 && ((LO_Env4 + LO_Env5)/2 > Bid || Bid > (SMMA + LO_Env1)/2)){
            OrderClose(OrderTicket(),Lots*margin4,Bid,Adjusted_Slippage,Aqua);
         }
         else if(OrderMagicNumber() == 4873 && ((LO_Env5 + LO_Env6)/2 > Bid || Bid > (SMMA + LO_Env1)/2)){
            OrderClose(OrderTicket(),Lots*margin5,Bid,Adjusted_Slippage,Aqua);
         }
         else if(OrderMagicNumber() == 4874 && (LO_Env6 + 1.0 > Bid || Bid > (SMMA + LO_Env1)/2)){
            OrderClose(OrderTicket(),Lots*margin6,Bid,Adjusted_Slippage,Aqua);
         }
         */
      }
   }

}
void OnTick()
{
//---
   Judge_Trade();
   return;
  }
//+------------------------------------------------------------------+
