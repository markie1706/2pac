//+------------------------------------------------------------------+
//|                                                         2pac.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

input int calculationPeriod = 40;
input int pipLeeway = 100;
input int numberOfInteractionsToBeSupport = 4; 
input int minimumPipDistanceBetweenTwoSupportLines = 120;

double low[], high[], close[], supportLines[], resistanceLines[];

//----Misc
static int BARS;
long chartID;
int uniqueLineNumber = 1;

int OnInit()
  {
   ArraySetAsSeries(low, true); 
   ArraySetAsSeries(high, true);  
   ArraySetAsSeries(close, true);
   
   BARS = Bars(_Symbol, _Period);
   
   chartID = ChartID();
   
   CopyLow(_Symbol, _Period, 1, calculationPeriod, low);  
   CopyHigh(_Symbol, _Period, 1, calculationPeriod, high);
   CopyClose(_Symbol, _Period, 1, calculationPeriod, close);
   
   double highOfPeriod = 0.0;
   double lowOfPeriod = 0.0;
   
   for(int o = calculationPeriod - 1 ; o >= 0 ; o--) {
      if (highOfPeriod == 0.0) {
         highOfPeriod = high[o];
         lowOfPeriod = low[o];
      } else {
         if (high[o] > highOfPeriod) {
            highOfPeriod = high[o];
         } 
         if (low[o] < lowOfPeriod) {
            lowOfPeriod = low[o];
         }
      }
   }
   
   double potentialSupportLinePrice = lowOfPeriod;
   do {
      int numberOfInteractons = 0;
      double upperBound = potentialSupportLinePrice + (_Point * pipLeeway);
      double lowerBound = potentialSupportLinePrice - (_Point * pipLeeway);
      double sum = 0.0;
      for(int b = calculationPeriod - 1 ; b >= 0 ; b--) {
         if(low[b] <= upperBound && low[b] >= lowerBound) {
            numberOfInteractons++;
            sum += low[b];
         }
      }
      if (numberOfInteractons > numberOfInteractionsToBeSupport) {
         double lineValue = sum / numberOfInteractons;
         double currentAsk = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         if (currentAsk < lineValue - (_Point * 110)) {
         
         } else {
            drawLine("Line" + uniqueLineNumber, lineValue, true);
            uniqueLineNumber++;
         } 
      }
      potentialSupportLinePrice = potentialSupportLinePrice + (_Point * 200);
   } while(potentialSupportLinePrice <= highOfPeriod);
   
   
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
   if(IsNewBar()) {
      for(int i=1;i<=uniqueLineNumber;i++) {
           ObjectDelete(0,"Line"+i);
      }
      
      CopyLow(_Symbol, _Period, 1, calculationPeriod, low);  
      CopyHigh(_Symbol, _Period, 1, calculationPeriod, high);
      CopyClose(_Symbol, _Period, 1, calculationPeriod, close);
      
      double highOfPeriod = 0.0;
      double lowOfPeriod = 0.0;
      
      for(int o = calculationPeriod - 1 ; o >= 0 ; o--) {
         if (highOfPeriod == 0.0) {
            highOfPeriod = high[o];
            lowOfPeriod = low[o];
         } else {
            if (high[o] > highOfPeriod) {
               highOfPeriod = high[o];
            } 
            if (low[o] < lowOfPeriod) {
               lowOfPeriod = low[o];
            }
         }
      }
      
      double potentialSupportLinePrice = lowOfPeriod;
      do {
         int numberOfInteractons = 0;
         double upperBound = potentialSupportLinePrice + (_Point * pipLeeway);
         double lowerBound = potentialSupportLinePrice - (_Point * pipLeeway);
         double sum = 0.0;
         for(int b = calculationPeriod - 1 ; b >= 0 ; b--) {
            if(low[b] <= upperBound && low[b] >= lowerBound) {
               sum += low[b];
               numberOfInteractons++;
            }
         }
         if (numberOfInteractons > numberOfInteractionsToBeSupport) {
            double lineValue = sum / numberOfInteractons;
            double currentAsk = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            if (currentAsk < lineValue - (_Point * 110)) {
            
            } else {
                bool goodToAdd3 = true;
                for (int q =ObjectsTotal(0,-1,OBJ_HLINE)-1; q>=0; q--) {
                     string name  = ObjectName(0, q);
                     double priceOfExistingLine = ObjectGetDouble(0, name, OBJPROP_PRICE);
                     //Comment(name + " " + priceOfExistingLine); 
                     if ( MathAbs((priceOfExistingLine - lineValue) * _Point) < minimumPipDistanceBetweenTwoSupportLines) {
                        bool lowerOfTheTwoIsOnChartAlready = false;
                        if (lineValue >= priceOfExistingLine) {
                           lowerOfTheTwoIsOnChartAlready = true; 
                        }
                        if (lowerOfTheTwoIsOnChartAlready) {
                           goodToAdd3 = false;
                        } else {
                           ObjectDelete(0, name);
                        }
                        
                     }
               }
               if (goodToAdd3) {
                  drawLine("Line" + uniqueLineNumber, lineValue, true);
                  uniqueLineNumber++;
               }
            } 
         }
         potentialSupportLinePrice = potentialSupportLinePrice + (_Point * 200);
      } while(potentialSupportLinePrice <= highOfPeriod);
        
   }
   
  }
//+------------------------------------------------------------------+

void drawLine(string name, double price, bool isSupport) {
   ObjectCreate(chartID, name, OBJ_HLINE, 0, 0, price);
   
   if(isSupport) {
      ObjectSetInteger(chartID, name, OBJPROP_COLOR, clrBlueViolet) ;
   } else {
      ObjectSetInteger(chartID, name, OBJPROP_COLOR, clrRed) ;
   }   
}


bool IsNewBar() {
      if(BARS != Bars(_Symbol, _Period))
      {
            BARS = Bars(_Symbol, _Period) ; 
            return(true) ;
      } 
      
      return(false) ; 
}