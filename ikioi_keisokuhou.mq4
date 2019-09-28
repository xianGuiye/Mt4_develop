//+------------------------------------------------------------------+
//|                                             ikioi_keisokuhou.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int Magic = 9497;
extern double Lot = 0.1;
extern int Slippage = 10;
int Adjusted_Slippage = 0;
double Ikioi = 0;
extern int BasePeriod = 480; 
int buys = 0;
int sells = 0;
extern double BuyBorder = 10;
extern double SellBorder = -10;
string Comments = "Ikioihou";
int Ticket = 0;

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
void CalculateCurrentOrders(string symbol)
  {
   buys=0;
   sells=0;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
  }
int AdjustSlippage(string Currency,int Slippage_Pips)
{ int Calculated_Slippage = 0;
  int Calculated_Digits =
  (int)MarketInfo(Symbol(),MODE_DIGITS);
  
  if(Calculated_Digits == 2 || Calculated_Digits == 4)
    {
      Calculated_Slippage = Slippage_Pips;
    }
  else if(Calculated_Digits == 3 ||
             Calculated_Digits == 5)
           {
             Calculated_Slippage = Slippage_Pips * 10;
           }
           
  return(Calculated_Slippage);
}


void JudgeTrade(){
   
   CalculateCurrentOrders(Symbol());
   
   if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) == true){
      
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic){
         if(OrderType() == OP_BUY && Ikioi < 0){
            
            OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Yellow);
         }
         if(OrderType() == OP_SELL && Ikioi > 0){
            
            OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Green);
         }
      }
   }else{

      if(Ikioi > BuyBorder){
         Ticket = OrderSend(Symbol(),OP_BUY,Lot,Ask,Adjusted_Slippage,0,0,Comments,Magic,0,Aqua);
      }
      if(Ikioi < SellBorder){
         Ticket = OrderSend(Symbol(),OP_SELL,Lot,Bid,Adjusted_Slippage,0,0,Comments,Magic,0,Magenta);
      }
   }
   
   
   
}
int start(){
   
   
   if(Volume[0]!=1){
      return(0);
   }
   
   
   
   if(Bars < BasePeriod){
      return(0);
   }
   
   
   Ikioi = iCustom(NULL,0,"ikioichi",BasePeriod,0,0);
   Print(Ikioi);
   Comment("0,1:"+iCustom(Symbol(),Period(),"ikioichi",BasePeriod,0,1)+"\n"+
           "1,1:"+iCustom(Symbol(),Period(),"ikioichi",BasePeriod,1,1)+"\n"
          );
   
   JudgeTrade();
   


      
      return(0);
 }