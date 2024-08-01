//+------------------------------------------------------------------+
//|                                              StrategyTest5EA.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialization code here
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Deinitialization code here
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Main trading logic will be called here

   // Check if the trend is bullish
   if(IsBullishTrend())
     {
      // Output message if the trend is bullish
      Print("The trend is bullish");

      // Check for retracement
      if(IsRetracement())
        {
         // Calculate Fibonacci levels
         double fibo50 = CalculateFibo50();

         // Check candlestick pattern at the 50.0 Fibonacci level
         if(CheckCandlestickPattern(fibo50))
           {
            // Execute a buy trade
            ExecuteBuyTrade(fibo50);
           }
        }
     }
   // Similar logic for bearish trend   
   
         for(int i=OrdersTotal()-1; i>=0; i--)
      {
        if(OrderSelect(i, SELECT_BY_POS)==false)
        {
          Print("Error in order selection: ", GetLastError());
          continue;
        }
      
        double entryPrice = OrderOpenPrice();
        double newStopLoss;
                
        // Check if the order is in profit
        if(OrderProfit()>30 && OrderProfit()<40)
        {
           // Move the stop loss to the entry point
           newStopLoss = entryPrice;
           double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
           Print("Stoploss moved to entry. SL: ", newStopLoss , " Current price: ", currentPrice);
        }
        else if(OrderProfit()>=40)
        {
           // Move the stop loss to 50 points above the entry point
           newStopLoss = NormalizeDouble(entryPrice + 2000 * Point, Digits);
           Print("Stoploss moved above entry. SL: ", newStopLoss);
        }
        else
        {
           // No modification needed
           continue;
        }
      
        if(OrderModify(OrderTicket(), entryPrice, newStopLoss, OrderTakeProfit(), 0, clrNONE)==false)
        {
          Print("Error in order modification: ", GetLastError());
        }
        else
        {
           Print("Stop loss moved for the order: ", OrderTicket());
        }
      }

  }

//+------------------------------------------------------------------+
//| Function to determine if the trend is bullish                    |
//+------------------------------------------------------------------+
bool IsBullishTrend()
  {
   // Implement logic to determine if the trend is bullish
   // This will involve checking the current price against the 200EMA on the D1 timeframe
   // Define the timeframe as D1 (daily)
    int timeframe = PERIOD_D1;
    // Define the EMA period as 200
    int emaPeriod = 200;
    // Get the current 200 EMA value for the current symbol
    double emaValue = iMA(NULL, timeframe, emaPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   // Get the current price
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    // Check if the current price is above the 200 EMA
    if (currentPrice > emaValue) {
        // If true, the trend is bullish
        Print("The trend is bullish");
        return true;
    } else {
        // If false, the trend is not bullish
        Print("The trend is not bullish");
        return false;
    }
   }
//+------------------------------------------------------------------+
//| Function to determine if a retracement has occurred              |
//+------------------------------------------------------------------+
bool IsRetracement()
  {
   // Implement logic to check for retracement
   // This will involve checking the current price against the highest closing price of the last three D1 candles
   
   double highestClose = 0;
    for(int i = 1; i <= 5; i++) {
        double closePrice = iClose(_Symbol, PERIOD_D1, i);
        if (closePrice > highestClose) {
            highestClose = closePrice;
        }
    }
  // Check if the trend is bullish
    if(IsBullishTrend()) {
        // Get the current price
        double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        
        // Check if the current price is below the highest close
        if(currentPrice < highestClose) {
            // If true, a retracement has occurred
            Print("A retracement has occurred");
            return true;
        }
    }
    // If the trend is not bullish or the condition is not met, no retracement
    return false;
  }
//+------------------------------------------------------------------+
//| Function to calculate the 50.0 Fibonacci retracement level       |
//+------------------------------------------------------------------+
double CalculateFibo50()
  {
   // Implement logic to calculate the 50.0 Fibonacci level
   // This will involve calculating the average of the high and low of the last three D1 candles
   
   // Check if the trend is bullish and if the retracement has occurred
    if(IsBullishTrend() && IsRetracement()) {
        // Get the highest high and lowest low of the last three D1 candles
        double highPrices[5];
        double lowPrices[11];
        
        // Copy high and low prices of the last three daily candles
        CopyHigh(_Symbol, PERIOD_D1, 0, 5, highPrices);
        CopyLow(_Symbol, PERIOD_D1, 0, 11, lowPrices);
        
        // Get the highest high and lowest low from the arrays
        double highestHigh = highPrices[ArrayMaximum(highPrices, 5, 0)];
        double lowestLow = lowPrices[ArrayMinimum(lowPrices, 11, 0)];
        
        // Calculate the range
        double range = highestHigh - lowestLow;
        
        // Calculate Fibonacci levels
        double fibo236 = lowestLow + range * 0.764;
        double fibo382 = lowestLow + range * 0.618;
        double fibo50 = lowestLow + range * 0.5; // The 50.0% level
        double fibo618 = lowestLow + range * 0.382;
        double fibo764 = lowestLow + range * 0.236;

        // Draw the Fibonacci retracement levels
        DrawHorizontalLine("Fibo_0", highestHigh, clrRed);
        DrawHorizontalLine("Fibo_236", fibo236, clrPurple);
        DrawHorizontalLine("Fibo_382", fibo382, clrPurple);
        DrawHorizontalLine("Fibo_50", fibo50, clrGreen);
        DrawHorizontalLine("Fibo_618", fibo618, clrPurple);
        DrawHorizontalLine("Fibo_764", fibo764, clrPurple);
        DrawHorizontalLine("Fibo_100", lowestLow, clrBlue);
        // Store the 50.0 Fibonacci level for later use in the algorithm
        
        DrawFibonacciRectangle(fibo50, fibo618);
        return fibo50;
    }
   return 0.0; // Placeholder return value
  }

//+------------------------------------------------------------------+
// Helper function to draw a horizontal line
//+------------------------------------------------------------------+
void DrawHorizontalLine(string name, double level, color clr) {
     if(ObjectFind(name) != -1) {
        ObjectMove(name, 0, Time[0], level);
    } else {
        ObjectCreate(name, OBJ_HLINE, 0, Time[0], level);
        ObjectSet(name, OBJPROP_COLOR, clr);
        ObjectSet(name, OBJPROP_WIDTH, 2);
    }
}
//+------------------------------------------------------------------+
// Function to draw a rectangle between the 50.0 and 61.8 Fibonacci levels
//+------------------------------------------------------------------+
void DrawFibonacciRectangle(double fibo50, double fibo618) {
    string rectName = "Fibo_Rectangle";
    datetime startTime = Time[0]- PeriodSeconds(PERIOD_D1) * 9; // Current candle's open time
    datetime endTime = Time[0] + (int)(PeriodSeconds(PERIOD_D1) * 0.5); // 3 days later

    // Delete the old rectangle if it exists
    if(ObjectFind(rectName) != -1) {
        ObjectDelete(rectName);
    }
    
    // Create a new rectangle with the updated levels
    ObjectCreate(rectName, OBJ_RECTANGLE, 0, startTime, fibo50, endTime, fibo618);
    ObjectSet(rectName, OBJPROP_COLOR, clrDodgerBlue);
    ObjectSet(rectName, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet(rectName, OBJPROP_WIDTH, 1);
    ObjectSet(rectName, OBJPROP_BACK, true); // Set to 'true' to display in the background
}
//+------------------------------------------------------------------+
//| Function to check the candlestick pattern at the Fibonacci level |
//+------------------------------------------------------------------+
bool CheckCandlestickPattern(double fibo50)
  {
    // Define arrays to store the open and close prices of the last four 5-minute candlesticks
    double openPrices[4] = {0}; // Initialize the array with zeros
    double closePrices[4] = {0}; // Initialize the array with zeros

    // Populate the arrays with the open and close prices
    for (int i = 0; i < 4; i++) {
        openPrices[i] = iOpen(Symbol(), PERIOD_M15, i);
        closePrices[i] = iClose(Symbol(), PERIOD_M15, i);
    }

    // Check for a bullish engulfing pattern
    if ((openPrices[2] > closePrices[2]) && (openPrices[1] < closePrices[1]) && (closePrices[1] > openPrices[2]) && (closePrices[1] < fibo50)) {
        Print("A bullish engulfing bar has occurred on the 5M chart.");
        return true;
    }

    // Check for a doji pattern
    if (MathAbs(openPrices[2] - closePrices[0]) < 0.2 * Point && (closePrices[2] < fibo50)) {
        Print("A doji candlestick pattern has occurred on the 5M chart.");
        return true;
    }

    // Check for a morning star pattern
    if ((openPrices[3] > closePrices[3]) && ((closePrices[2] - openPrices[2]) < (openPrices[3] - closePrices[3])) && (openPrices[1] < closePrices[1]) && (closePrices[1] > openPrices[3] + 0.5 * (openPrices[3] - closePrices[3])) && (closePrices[1] < fibo50)) {
        Print("The morning star candlestick pattern has occurred on the 5M chart.");
        return true;
    }

    // Check for a hammer (pin bar) pattern
    double bodyLength = MathAbs(openPrices[2] - closePrices[2]);
    double lowerShadowLength = iLow(Symbol(), PERIOD_M15, 2) - MathMin(openPrices[2], closePrices[2]);
    if ((lowerShadowLength >= 2 * bodyLength) && (closePrices[2] < fibo50)) {
        Print("The hammer (pin bar) pattern has occurred on the 5M chart.");
        return true;
    }

    // Check for a harami (inside bar) pattern
    if ((openPrices[2] > closePrices[2]) && (openPrices[1] < closePrices[1]) && (iHigh(Symbol(), PERIOD_M15, 2) > iHigh(Symbol(), PERIOD_M15, 1)) && (iLow(Symbol(), PERIOD_M15, 2) < iLow(Symbol(), PERIOD_M15, 1)) && (closePrices[2] < fibo50)) {
        Print("The harami candlestick pattern has occurred on the 5M chart.");
        return true;
    }

    return false; // If no pattern is found, return false 
}
//+------------------------------------------------------------------+
//| Function to execute a buy trade                                  |
//+------------------------------------------------------------------+
void ExecuteBuyTrade(double fiboLevel)
  {
   // Implement logic to execute a buy trade
   // This will involve sending a buy order with the specified stop loss
   // Execute a buy trade with stoploss 300 pips away from the low of the current 5M candle   
   // Refresh the rates
   RefreshRates();
   double takeProfit = iHigh(Symbol(), PERIOD_D1, 2); 
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double askPrice = MarketInfo(_Symbol, MODE_ASK);
   double bidPrice = MarketInfo(_Symbol, MODE_BID);
   double balance = AccountBalance();
   double lotSize;
   double lowestLow[2] = {};
   CopyLow(_Symbol, PERIOD_D1, 0, 2, lowestLow);
   double stopLoss = lowestLow[ArrayMinimum(lowestLow, 2, 0)];
             
   //Calculate the lot size based on the the account size
   if(balance >= 100){
      lotSize = MathFloor(balance / 100);
   } 
   else{
      lotSize = balance / 100;
   }
   //Set the lot size to 0.01, if the account balance is R1.00 or less
   if(balance <= 1){
      lotSize = 0.01;
   }
   
   //Execute Buy trade
   int ticket = OrderSend(_Symbol, OP_BUY, lotSize, askPrice, 3, stopLoss, takeProfit, "Buy Order", 0, 0, clrGreen);
                
   // Check if the order was executed successfully
   if(ticket < 0) {
      Print("OrderSend failed with error #", GetLastError());
   }   
  }
//+------------------------------------------------------------------+