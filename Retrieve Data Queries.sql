
/***Category level data**/
SELECT GEO,
       WeekEnding,
	   SUM(BaseDollars) as CatbaseDollars,
        SUM(BaseUnits) as CatbaseUnits,
        SUM(BaseDollars)/SUM(BaseUnits) as CatbasePrice,
	   SUM(Dollars) as CatDollars,
	   SUM(Units) as CatUnits,
	   SUM(ACV)/100 as Catdist_num,
	   SUM(PACV_Discount)/100 as CatDiscount_num,
	   SUM(PACV_FeatWODisp)/100 as CatFeatWODisp_num,
	   SUM(PACV_DispWOFeat)/100 as CatDispWOFeat_num,
	   SUM(PACV_FeatAndDisp)/100 as CatFeatAndDisp_num,
	   SUM(Units_Feature) as CatUnits_Feature,
	   SUM(Dollars_Feature) as CatDollars_Feature,
	   SUM(Units_Display) as CatUnits_Display,
	   SUM(Dollars_Display) as CatDollars_Display,
	   SUM(Units_TPR) as CatUnits_TPR,
	   SUM(Dollars_TPR) as CatDollars_TPR,
	   SUM(Units_FeatAndDisp) as CatUnits_FeatAndDisp,
	   SUM(Dollars_FeatAndDisp) as CatDollars_FeatAndDisp,
           SUM(Dollars_Feature)/nullif(SUM(Units_Feature),0) as CatPrice_Feature,
           SUM(Dollars_Display)/nullif(SUM(Units_Display),0) as CatPrice_Display,
           SUM(Dollars_FeatAndDisp)/nullif(SUM(Units_FeatAndDisp),0) as CatPrice_FeatAndDisp,
           SUM(Dollars_TPR)/nullif(SUM(Units_TPR),0) as CatPrice_TPR,	      
	   SUM((Dollars_Display/nullif(Units_Display, 0)/(nullif(BaseDollars,0)/nullif(BaseUnits,0)))*Units_Display)/SUM(Units_Display) as CatPI_Display,
	   SUM((Dollars_Feature/nullif(Units_Feature, 0)/(nullif(BaseDollars,0)/nullif(BaseUnits,0)))*Units_Feature)/SUM(Units_Feature) as CatPI_Feature,
	   SUM((Dollars_FeatAndDisp/nullif(Units_FeatAndDisp, 0)/(nullif(BaseDollars,0)/nullif(BaseUnits,0)))*Units_FeatAndDisp)/SUM(Units_FeatAndDisp) as CatPI_FeatAndDisp,
	   SUM(Dollars_TPR/nullif(Units_TPR, 0)/((nullif(BaseDollars,0))/(nullif(BaseUnits,0)))*Units_TPR)/SUM(Units_TPR) as CatPI_TPR
  FROM [CSOM_MSBA_ULDATA].[dbo].[t_WeeklySales]
  WHERE Attr1 = 'GEN HAIRCARE'
  GROUP BY GEO, WeekEnding
  ORDER BY GEO, WeekEnding;



/***Segment level data
same query with Category level data query except changing the name and group by
need to calculate share related data in R**/

SELECT GEO,
        WeekEnding,
	   SUM(BaseDollars) as SegbaseDollars,
        SUM(BaseUnits) as SegbaseUnits,
        SUM(BaseDollars)/SUM(BaseUnits) as SegbasePrice,
	   SUM(Dollars) as SegDollars,
	   SUM(Units) as SegUnits,
	   SUM(ACV)/100 as Segdist_num,
	   SUM(PACV_Discount)/100 as SegDiscount_num,
	   SUM(PACV_FeatWODisp)/100 as SegFeatWODisp_num,
	   SUM(PACV_DispWOFeat)/100 as SegDispWOFeat_num,
	   SUM(PACV_FeatAndDisp)/100 as SegFeatAndDisp_num,
	   SUM(Units_Feature) as SegUnits_Feature,
	   SUM(Dollars_Feature) as SegDollars_Feature,
	   SUM(Units_Display) as SegUnits_Display,
	   SUM(Dollars_Display) as SegDollars_Display,
	   SUM(Units_TPR) as SegUnits_TPR,
	   SUM(Dollars_TPR) as SegDollars_TPR,
	   SUM(Units_FeatAndDisp) as SegUnits_FeatAndDisp,
	   SUM(Dollars_FeatAndDisp) as SegDollars_FeatAndDisp,
           SUM(Dollars_Feature)/nullif(SUM(Units_Feature),0) as SegPrice_Feature,
           SUM(Dollars_Display)/nullif(SUM(Units_Display),0) as SegPrice_Display,
           SUM(Dollars_FeatAndDisp)/nullif(SUM(Units_FeatAndDisp),0) as SegPrice_FeatAndDisp,
           SUM(Dollars_TPR)/nullif(SUM(Units_TPR),0) as CatPrice_TPR,	   
	   SUM((Dollars_Display/nullif(Units_Display, 0)/(nullif(BaseDollars,0)/nullif(BaseUnits,0)))*Units_Display)/SUM(Units_Display) as SegPI_Display,
	   SUM((Dollars_Feature/nullif(Units_Feature, 0)/(nullif(BaseDollars,0)/nullif(BaseUnits,0)))*Units_Feature)/SUM(Units_Feature) as SegPI_Feature,
	   SUM((Dollars_FeatAndDisp/nullif(Units_FeatAndDisp, 0)/(nullif(BaseDollars,0)/nullif(BaseUnits,0)))*Units_FeatAndDisp)/SUM(Units_FeatAndDisp) as SegPI_FeatAndDisp,
	   SUM(Dollars_TPR/nullif(Units_TPR, 0)/((nullif(BaseDollars,0))/(nullif(BaseUnits,0)))*Units_TPR)/SUM(Units_TPR) as SegPI_TPR
  FROM [CSOM_MSBA_ULDATA].[dbo].[t_WeeklySales]
  WHERE Attr1 = 'GEN HAIRCARE'
    AND Attr2 = 'SHAMPOO'
	AND Attr3 = 'WOMEN'
  GROUP BY GEO, WeekEnding
  ORDER BY GEO, WeekEnding;
















