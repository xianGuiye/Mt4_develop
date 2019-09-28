//+------------------------------------------------------------------+
//|                                             ikioi_keisokuhou.mq4 |
//|                                       Copyright 2018,　xianGuiye. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018,　xianGuiye."
#property version   "1.00"
#property strict
#include "../include/myini.mqh"

extern int Magic = 9497;
extern double Lot = 0.1;
extern int Slippage = 10;
extern int BasePeriod = 288; 
extern double BuyBorder = 10;
extern double SellBorder = -10;

int Adjusted_Slippage = 0;
double Ikioi = 0;
int buys = 0;
int sells = 0;
int Ticket = 0;
double Ikioi_Sum=0;
double Ikioi_Ave=0;
double test = 0;
string Comments = "Ikioihou";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Adjusted_Slippage =
   AdjustSlippage(Symbol(),Slippage);
   
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


void JudgeTrade(){
   
   CalculateCurrentOrders(Symbol());
   
   if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) == true){
      
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic){
         if(OrderType() == OP_BUY && test < 0){
            
            OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Yellow);
         }
         if(OrderType() == OP_SELL && test > 0){
            
            OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Green);
         }
      }
   }else{

      if(test > BuyBorder){
         Ticket = OrderSend(Symbol(),OP_BUY,Lot,Ask,Adjusted_Slippage,0,0,Comments,Magic,0,Aqua);
      }
      if(test < SellBorder){
         Ticket = OrderSend(Symbol(),OP_SELL,Lot,Bid,Adjusted_Slippage,0,0,Comments,Magic,0,Magenta);
      }
   }
   
   
   
}
double CulculateIkioi(){
int i;
   for(i=1; i<=BasePeriod; i++)
        {
         Ikioi = Volume[i]*(Close[i]*2-High[i]-Low[i]);
         Ikioi_Sum = Ikioi_Sum + Ikioi;
        }
    
    Ikioi_Ave = Ikioi_Sum/BasePeriod;

   return Ikioi_Ave;
}
int start(){
   
   
   if(Volume[0]!=1){
      return(0);
   }
   
   
   
   if(Bars < BasePeriod){
      return(0);
   }
   
   
   //CulculateIkioi();
   //Print(Ikioi_Ave);
   
   test = iCustom(NULL,0,"TAKAYA",0,0);
   Print(test);
   
   JudgeTrade();
   


      
      return(0);
 }