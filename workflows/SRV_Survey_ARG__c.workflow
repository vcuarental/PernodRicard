<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SRV_UpdateImpact2_AR</fullName>
        <field>Impact_ARG__c</field>
        <formula>IF( 
( (IF(ISPICKVAL(GastronomicHub_AR__c, &quot;YES&quot;),1,0)*(9/93)+ 
IF(ISPICKVAL(IsCorner_AR__c,&quot;YES&quot;),1,0)*(8/93)+ 
IF(ISPICKVAL(BrandsInDrinks_AR__c,&quot;YES&quot;),1,0)*(7/93)+ 
IF(ISPICKVAL(NeighborhoodSocioeconomicLevel_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(NeighborhoodSocioeconomicLevel_AR__c,&quot;MIDDLE&quot;),1,0))*(10/93)+ 
IF(ISPICKVAL(StreetTransit_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(StreetTransit_AR__c,&quot;MIDDLE&quot;),1,0))*(4/93)+ 
IF(ISPICKVAL(BrandExhibition_AR__c,&quot;YES&quot;),1,0)*(7/93)+ 
IF(ISPICKVAL(CounterShare_AR__c,&quot;0 and 10%&quot;),1,IF(ISPICKVAL(CounterShare_AR__c,&quot;20 and 30%&quot;),2,3))*(8/93)+ 
IF(ISPICKVAL(EmployeesSposonredUniform_AR__c, &quot;YES&quot;),1,0)*(7/93)+ 
IF(ISPICKVAL(BrandImage_AR__c,&quot;YES&quot;),1,0)*(8/93)+ 
IF(ISPICKVAL(Actionable_AR__c,&quot;YES&quot;),1,0)*(3/93)+ 
IF(ISPICKVAL(PositionRestaurantBrand_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(PositionRestaurantBrand_AR__c,&quot;MIDDLE&quot;),1,0))*(9/93)+ 
IF(ISPICKVAL(Seasonal_AR__c,&quot;YES&quot;),1,0)*(6/93)+ 
IF(ISPICKVAL(Branch_AR__c,&quot;YES&quot;),1,0)*(7/93) ) /1.41935483870968) &gt; 0.8, &quot;A&quot;, 
IF( 
((IF(ISPICKVAL(GastronomicHub_AR__c, &quot;YES&quot;),1,0)*(9/93)+ 
IF(ISPICKVAL(IsCorner_AR__c, &quot;YES&quot;),1,0)*(8/93)+ 
IF(ISPICKVAL(BrandsInDrinks_AR__c, &quot;YES&quot;),1,0)*(7/93)+ 
IF(ISPICKVAL(NeighborhoodSocioeconomicLevel_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(NeighborhoodSocioeconomicLevel_AR__c,&quot;MIDDLE&quot;),1,0))*(10/93)+ 
IF(ISPICKVAL(StreetTransit_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(StreetTransit_AR__c,&quot;MIDDLE&quot;),1,0))*(4/93)+ 
IF(ISPICKVAL(BrandExhibition_AR__c, &quot;YES&quot;),1,0)*(7/93)+ 
IF(ISPICKVAL(CounterShare_AR__c,&quot;0 and 10%&quot;),1,IF(ISPICKVAL(CounterShare_AR__c,&quot;20 and 30%&quot;),2,3))*(8/93)+ 
IF(ISPICKVAL(EmployeesSposonredUniform_AR__c, &quot;YES&quot;),1,0)*(7/93)+ 
IF(ISPICKVAL(BrandImage_AR__c, &quot;YES&quot;),1,0)*(8/93)+ 
IF(ISPICKVAL(Actionable_AR__c, &quot;YES&quot;),1,0)*(3/93)+ 
IF(ISPICKVAL(PositionRestaurantBrand_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(PositionRestaurantBrand_AR__c,&quot;MIDDLE&quot;),1,0))*(9/93)+ 
IF(ISPICKVAL(Seasonal_AR__c, &quot;YES&quot;),1,0)*(6/93)+ 
IF(ISPICKVAL(Branch_AR__c, &quot;YES&quot;),1,0)*(7/93) /1.41935483870968 ) &gt; 0.5), &quot;B&quot;, &quot;C&quot;))</formula>
        <name>SRV_UpdateImpact2_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SRV_UpdateImpact3_AR</fullName>
        <field>Impact_ARG__c</field>
        <formula>IF(
( ( IF(ISPICKVAL(Seasonal_AR__c, &quot;YES&quot;),1,0)*(6/59)
+
IF(ISPICKVAL(AccessLists_AR__c, &quot;YES&quot;),1,0)*(9/59)
+
IF(ISPICKVAL(Actionable_AR__c, &quot;YES&quot;),1,0)*(3/59)
+
IF(ISPICKVAL(PublicSocioeconomicLevel_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(PublicSocioeconomicLevel_AR__c,&quot;MIDDLE&quot;),1,0))*(10/59)
+
IF(ISPICKVAL(HasTables_AR__c, &quot;YES&quot;),1,0)*(8/59)
+
IF(ISPICKVAL(VipArea_AR__c, &quot;YES&quot;),1,0)*(8/59)
+
IF(ISPICKVAL(BrandExhibition_AR__c, &quot;YES&quot;),1,0)*(7/59)
+
IF(ISPICKVAL(StreetTransit_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(StreetTransit_AR__c,&quot;MIDDLE&quot;),1,0))*(8/59) ) / 1.30508474576271   ) &gt; 0.8, &quot;A&quot;,
 IF(
((IF(ISPICKVAL(Seasonal_AR__c, &quot;YES&quot;),1,0)*(6/59)
+
IF(ISPICKVAL(AccessLists_AR__c, &quot;YES&quot;),1,0)*(9/59)
+
IF(ISPICKVAL(Actionable_AR__c, &quot;YES&quot;),1,0)*(3/59)
+
IF(ISPICKVAL(PublicSocioeconomicLevel_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(PublicSocioeconomicLevel_AR__c,&quot;MIDDLE&quot;),1,0))*(10/59)
+
IF(ISPICKVAL(HasTables_AR__c, &quot;YES&quot;),1,0)*(8/59)
+
IF(ISPICKVAL(VipArea_AR__c, &quot;YES&quot;),1,0)*(8/59)
+
IF(ISPICKVAL(BrandExhibition_AR__c, &quot;YES&quot;),1,0)*(7/59)
+
IF(ISPICKVAL(StreetTransit_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(StreetTransit_AR__c,&quot;MIDDLE&quot;),1,0))*(8/59)) / 1.30508474576271 ) &gt; 0.5, &quot;B&quot;, &quot;C&quot;))</formula>
        <name>SRV_UpdateImpact3_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SRV_UpdateImpact_AR</fullName>
        <field>Impact_ARG__c</field>
        <formula>IF(
((IF(ISPICKVAL(NeighborhoodSocioeconomicLevel_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(NeighborhoodSocioeconomicLevel_AR__c,&quot;MIDDLE&quot;),1,0))*(10/122)
+
IF(ISPICKVAL(StreetTransit_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(StreetTransit_AR__c,&quot;MIDDLE&quot;),1,0))*(8/122)
+
IF(ISPICKVAL(IsCorner_AR__c, &quot;YES&quot;),1,0)*(8/122)
+
IF(ISPICKVAL(GastronomicHub_AR__c, &quot;YES&quot;),1,0)*(9/122)
+
IF(ISPICKVAL(Seasonal_AR__c, &quot;YES&quot;),1,0)*(6/122)
+
IF(ISPICKVAL(Branch_AR__c, &quot;YES&quot;),1,0)*(7/122)
+
IF(ISPICKVAL(BrandExhibition_AR__c, &quot;YES&quot;),1,0)*(7/122)
+
IF(ISPICKVAL(Actionable_AR__c, &quot;YES&quot;),1,0)*(3/122)
+
IF(ISPICKVAL(Sommelier_AR__c, &quot;YES&quot;),1,0)*(8/122)
+
IF(ISPICKVAL(ImportedWines_AR__c, &quot;YES&quot;),1,0)*(7/122)
+
IF(ISPICKVAL(CounterSizeMeters_AR__c, &quot;YES&quot;),1,0)*(6/122)
+
IF(ISPICKVAL(PositionRestaurantBrand_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(PositionRestaurantBrand_AR__c,&quot;MIDDLE&quot;),1,0))*(9/122)
+
IF(ISPICKVAL(ValetParking_AR__c, &quot;YES&quot;),1,0)*(6/122)
+
IF(ISPICKVAL(Security_AR__c, &quot;YES&quot;),1,0)*(6/122)
+
IF(ISPICKVAL(Receptionist_AR__c, &quot;YES&quot;),1,0)*(7/122)
+
IF(ISPICKVAL(WineMenu_AR__c,&quot;0&quot;),0,IF(ISPICKVAL(WineMenu_AR__c,&quot;0 to 20&quot;),2,IF(ISPICKVAL(WineMenu_AR__c,&quot;20 to 50&quot;),2,3)))*(10/122)
+
IF(ISPICKVAL(WineCellar_AR__c, &quot;YES&quot;),1,0)*(5/122))/1.39) &gt; 0.8, &quot;A&quot;,
IF(
((IF(ISPICKVAL(NeighborhoodSocioeconomicLevel_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(NeighborhoodSocioeconomicLevel_AR__c,&quot;MIDDLE&quot;),1,0))*(10/122)
+
IF(ISPICKVAL(StreetTransit_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(StreetTransit_AR__c,&quot;MIDDLE&quot;),1,0))*(8/122)
+
IF(ISPICKVAL(IsCorner_AR__c, &quot;YES&quot;),1,0)*(8/122)
+
IF(ISPICKVAL(GastronomicHub_AR__c, &quot;YES&quot;),1,0)*(9/122)
+
IF(ISPICKVAL(Seasonal_AR__c, &quot;YES&quot;),1,0)*(6/122)
+
IF(ISPICKVAL(Branch_AR__c, &quot;YES&quot;),1,0)*(7/122)
+
IF(ISPICKVAL(BrandExhibition_AR__c, &quot;YES&quot;),1,0)*(7/122)
+
IF(ISPICKVAL(Actionable_AR__c, &quot;YES&quot;),1,0)*(3/122)
+
IF(ISPICKVAL(Sommelier_AR__c, &quot;YES&quot;),1,0)*(8/122)
+
IF(ISPICKVAL(ImportedWines_AR__c, &quot;YES&quot;),1,0)*(7/122)
+
IF(ISPICKVAL(CounterSizeMeters_AR__c, &quot;YES&quot;),1,0)*(6/122)
+
IF(ISPICKVAL(PositionRestaurantBrand_AR__c,&quot;HIGH&quot;),2,IF(ISPICKVAL(PositionRestaurantBrand_AR__c,&quot;MIDDLE&quot;),1,0))*(9/122)
+
IF(ISPICKVAL(ValetParking_AR__c, &quot;YES&quot;),1,0)*(6/122)
+
IF(ISPICKVAL(Security_AR__c, &quot;YES&quot;),1,0)*(6/122)
+
IF(ISPICKVAL(Receptionist_AR__c, &quot;YES&quot;),1,0)*(7/122)
+
IF(ISPICKVAL(WineMenu_AR__c,&quot;0&quot;),0,IF(ISPICKVAL(WineMenu_AR__c,&quot;0 to 20&quot;),2,IF(ISPICKVAL(WineMenu_AR__c,&quot;20 to 50&quot;),2,3)))*(10/122)
+
IF(ISPICKVAL(WineCellar_AR__c, &quot;YES&quot;),1,0)*(5/122))/1.39) &gt; 0.5, &quot;B&quot;,&quot;C&quot;))</formula>
        <name>SRV_UpdateImpact_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SRV_UpdateProductivity114_AR</fullName>
        <field>Rating_segmentation_targert_market__c</field>
        <formula>Impact_ARG__c  + TEXT(Productivity_AR__c)</formula>
        <name>SRV_UpdateSegmentationRating_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>AccountName_AR__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SRV_UpdateProductivity1_AR</fullName>
        <field>Productivity2__c</field>
        <formula>IF(
((IF(ISPICKVAL(ExcecutMenu_AR__c, &quot;YES&quot;),1,0)*(6/122*111)
+
IF(ISPICKVAL(Delivery_AR__c, &quot;YES&quot;),1,0)*(6/122*111)
+
IF(ISPICKVAL(OutdoorArea_AR__c, &quot;YES&quot;),1,0)*(7/122*111)
+
IF(ISPICKVAL(OwnParking_AR__c, &quot;YES&quot;),1,0)*(8/122*111)
+
IF(ISPICKVAL(AcceptsCreditCardWhichOnes_AR__c, &quot;YES&quot;),1,0)*(6/111*100)
+
IF(ISPICKVAL(AverageDaySale_AR__c ,&quot;50 to 100&quot;),1,IF(ISPICKVAL(AverageDaySale_AR__c ,&quot;101 to 150&quot;),2,3))*(8/122*100)
+
IF(ISPICKVAL(AverageNigthSale_AR__c,&quot;80 to 100&quot;),1,IF(ISPICKVAL(AverageNigthSale_AR__c,&quot;101 to 150&quot;),2,IF(ISPICKVAL(AverageNigthSale_AR__c,&quot;151 to 200&quot;),3,4)))*(10/59*100)
+
IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;0 to 10 boxes&quot;),1,IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;10 to 20 boxes&quot;),2,IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;20 to 30 boxes&quot;),3,4)))*(10/59*100)
+
IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;up to 30&quot;),1,IF(ISPICKVAL(QtyDailyMeals_AR__c,&quot;31 to 50&quot;),2,IF(ISPICKVAL(QtyDailyMeals_AR__c,&quot;51 to 100&quot;),3,4)))*(8/59*100)
+
IF(ISPICKVAL(QtyNightlyMeals_AR__c,&quot;up to 30&quot;),1,IF(ISPICKVAL(QtyNightlyMeals_AR__c,&quot;31 to 50&quot;),2,IF(ISPICKVAL(QtyNightlyMeals_AR__c,&quot;51 to 100&quot;),3,4)))*(10/59*100)
+
IF(ISPICKVAL(WiFi_AR__c, &quot;YES&quot;),1,0)*(3/111*100)
+
IF(ISPICKVAL(EventsandCatering_AR__c, &quot;YES&quot;),1,0)*(4/111*100)
+
IF(ISPICKVAL(Winebyglass_AR__c, &quot;YES&quot;),1,0)*(6/111*100)
+
IF(ISPICKVAL(DrinksMenu_AR__c, &quot;YES&quot;),1,0)*(8/111*100)
+
IF(ISPICKVAL(BenefitsClub_AR__c, &quot;YES&quot;),1,0)*(7/111*100)
+
IF(ISPICKVAL(HouseWineWhich_AR__c, &quot;YES&quot;),1,0)*(4/111*100)) /2.01) &gt; 0.8,
 1, IF(
((IF(ISPICKVAL(ExcecutMenu_AR__c, &quot;YES&quot;),1,0)*(6/122*111)
+
IF(ISPICKVAL(Delivery_AR__c, &quot;YES&quot;),1,0)*(6/122*111)
+
IF(ISPICKVAL(OutdoorArea_AR__c, &quot;YES&quot;),1,0)*(7/122*111)
+
IF(ISPICKVAL(OwnParking_AR__c, &quot;YES&quot;),1,0)*(8/122*111)
+
IF(ISPICKVAL(AcceptsCreditCardWhichOnes_AR__c, &quot;YES&quot;),1,0)*(6/111*100)
+
IF(ISPICKVAL(AverageDaySale_AR__c ,&quot;50 to 100&quot;),1,IF(ISPICKVAL(AverageDaySale_AR__c ,&quot;101 to 150&quot;),2,3))*(8/122*100)
+
IF(ISPICKVAL(AverageNigthSale_AR__c,&quot;80 to 100&quot;),1,IF(ISPICKVAL(AverageNigthSale_AR__c,&quot;101 to 150&quot;),2,IF(ISPICKVAL(AverageNigthSale_AR__c,&quot;151 to 200&quot;),3,4)))*(10/59*100)
+
IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;0 to 10 boxes&quot;),1,IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;10 to 20 boxes&quot;),2,IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;20 to 30 boxes&quot;),3,4)))*(10/59*100)
+
IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;up to 30&quot;),1,IF(ISPICKVAL(QtyDailyMeals_AR__c,&quot;31 to 50&quot;),2,IF(ISPICKVAL(QtyDailyMeals_AR__c,&quot;51 to 100&quot;),3,4)))*(8/59*100)
+
IF(ISPICKVAL(QtyNightlyMeals_AR__c,&quot;up to 30&quot;),1,IF(ISPICKVAL(QtyNightlyMeals_AR__c,&quot;31 to 50&quot;),2,IF(ISPICKVAL(QtyNightlyMeals_AR__c,&quot;51 to 100&quot;),3,4)))*(10/59*100)
+
IF(ISPICKVAL(WiFi_AR__c, &quot;YES&quot;),1,0)*(3/111*100)
+
IF(ISPICKVAL(EventsandCatering_AR__c, &quot;YES&quot;),1,0)*(4/111*100)
+
IF(ISPICKVAL(Winebyglass_AR__c, &quot;YES&quot;),1,0)*(6/111*100)
+
IF(ISPICKVAL(DrinksMenu_AR__c, &quot;YES&quot;),1,0)*(8/111*100)
+
IF(ISPICKVAL(BenefitsClub_AR__c, &quot;YES&quot;),1,0)*(7/111*100)
+
IF(ISPICKVAL(HouseWineWhich_AR__c, &quot;YES&quot;),1,0)*(4/111*100))/2.01) &gt; 0.5, 2, 3))</formula>
        <name>SRV_UpdateProductivity1_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SRV_UpdateProductivity2_AR</fullName>
        <field>Productivity2__c</field>
        <formula>IF(
((IF(ISPICKVAL(Capacity_AR__c,&quot;0 to 50&quot;),1,IF(ISPICKVAL(Capacity_AR__c,&quot;51 to 150&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(SmokingArea_AR__c, &quot;YES&quot;),1,0)*(7/93)
+
IF(ISPICKVAL(OutdoorArea_AR__c, &quot;YES&quot;),1,0)*(6/93)
+
IF(ISPICKVAL(AverageTicket_AR__c,&quot;50 to 100&quot;),1,IF(ISPICKVAL(AverageTicket_AR__c,&quot;101 to 150&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(OffersFood_AR__c, &quot;YES&quot;),1,0)*(4/93)
+
IF(ISPICKVAL(BenefitsClub_AR__c, &quot;YES&quot;),1,0)*(7/93)
+
IF(ISPICKVAL(AfterOffice_AR__c, &quot;YES&quot;),1,0)*(7/93)
+
IF(ISPICKVAL(NumberBottlesCounter_AR__c,&quot;0-30&quot;),1,IF(ISPICKVAL(NumberBottlesCounter_AR__c,&quot;30-60&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(AverageAmountPerson_AR__c,&quot;1 Drink&quot;),1,IF(ISPICKVAL(AverageAmountPerson_AR__c,&quot;2 Drinks&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(WeeklyBoxesWhiskysVodkasFernet_AR__c,&quot;0 to 5 boxes&quot;),1,IF(ISPICKVAL(WeeklyBoxesWhiskysVodkasFernet_AR__c,&quot;5 to 10 boxes&quot;),2,IF(ISPICKVAL(WeeklyBoxesWhiskysVodkasFernet_AR__c,&quot;10 to 20 boxes&quot;),3,4)))*(10/93)
+
IF(ISPICKVAL(HappyHours_AR__c, &quot;YES&quot;),1,0)*(5/93)
+
IF(ISPICKVAL(HoursOpen_AR__c,&quot;0 - 4hs&quot;),1,IF(ISPICKVAL(HoursOpen_AR__c,&quot;4 - 8hs&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(AcceptsCreditCardWhichOnes_AR__c, &quot;YES&quot;),1,0)*(6/93)) / 2.20430107526882) &gt; 0.8, 1, 
 IF(
((IF(ISPICKVAL(Capacity_AR__c,&quot;0 to 50&quot;),1,IF(ISPICKVAL(Capacity_AR__c,&quot;51 to 150&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(SmokingArea_AR__c, &quot;YES&quot;),1,0)*(7/93)
+
IF(ISPICKVAL(OutdoorArea_AR__c, &quot;YES&quot;),1,0)*(6/93)
+
IF(ISPICKVAL(AverageTicket_AR__c,&quot;50 to 100&quot;),1,IF(ISPICKVAL(AverageTicket_AR__c,&quot;101 to 150&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(OffersFood_AR__c, &quot;YES&quot;),1,0)*(4/93)
+
IF(ISPICKVAL(BenefitsClub_AR__c, &quot;YES&quot;),1,0)*(7/93)
+
IF(ISPICKVAL(AfterOffice_AR__c, &quot;YES&quot;),1,0)*(7/93)
+
IF(ISPICKVAL(NumberBottlesCounter_AR__c,&quot;0-30&quot;),1,IF(ISPICKVAL(NumberBottlesCounter_AR__c,&quot;30-60&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(AverageAmountPerson_AR__c,&quot;1 Drink&quot;),1,IF(ISPICKVAL(AverageAmountPerson_AR__c,&quot;2 Drinks&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(WeeklyBoxesWhiskysVodkasFernet_AR__c,&quot;0 to 5 boxes&quot;),1,IF(ISPICKVAL(WeeklyBoxesWhiskysVodkasFernet_AR__c,&quot;5 to 10 boxes&quot;),2,IF(ISPICKVAL(WeeklyBoxesWhiskysVodkasFernet_AR__c,&quot;10 to 20 boxes&quot;),3,4)))*(10/93)
+
IF(ISPICKVAL(HappyHours_AR__c, &quot;YES&quot;),1,0)*(5/93)
+
IF(ISPICKVAL(HoursOpen_AR__c,&quot;0 - 4hs&quot;),1,IF(ISPICKVAL(HoursOpen_AR__c,&quot;4 - 8hs&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(AcceptsCreditCardWhichOnes_AR__c, &quot;YES&quot;),1,0)*(6/93)) / 2.20430107526882) &gt; 0.5, 2, 3) )</formula>
        <name>SRV_UpdateProductivity2_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SRV_UpdateProductivity3_AR</fullName>
        <field>Productivity_AR__c</field>
        <formula>IF(
(  ( IF(ISPICKVAL(OwnParking_AR__c, &quot;YES&quot;),1,0)*(8/81)+

IF(ISPICKVAL(Capacity_AR__c,&quot;100 to 350&quot;),1,IF(ISPICKVAL(Capacity_AR__c,&quot;351 to 800&quot;),2,3))*(9/81)+

IF(ISPICKVAL(NumberDanceFloors_AR__c,&quot;1 Dance Floor&quot;),1,IF(ISPICKVAL(NumberDanceFloors_AR__c,&quot;2 Dance Floors&quot;),2,3))*(8/81)+

IF(ISPICKVAL(NumberCounters_AR__c,&quot;1 Counter&quot;),1,IF(ISPICKVAL(NumberCounters_AR__c,&quot;2 Counters&quot;),2,IF(ISPICKVAL(NumberCounters_AR__c,&quot;3 Counters&quot;),3,4)))*(10/81)+

IF(ISPICKVAL(AccessPrice_AR__c,&quot;30 to 80&quot;),1,IF(ISPICKVAL(AccessPrice_AR__c,&quot;80 to 150&quot;),2,3))*(7/81)+

IF(ISPICKVAL(AcceptsCreditCardWhichOnes_AR__c, &quot;YES&quot;),1,0)*(6/81)+

IF(ISPICKVAL(Dinner_AR__c, &quot;YES&quot;),1,0)*(7/81)+

IF(ISPICKVAL(WeeklyBoxesSparklingChamp_AR__c,&quot;0 to 50 boxes&quot;),1,IF(ISPICKVAL(WeeklyBoxesSparklingChamp_AR__c,&quot;50 to 150 boxes&quot;),2,IF(ISPICKVAL(WeeklyBoxesSparklingChamp_AR__c,&quot;150 to 250 boxes&quot;),3,4)))*(10/81)+

IF(ISPICKVAL(OutdoorArea_AR__c, &quot;YES&quot;),1,0)*(6/81) +

IF(ISPICKVAL(WeeklyBoxesVodkaFernetRon_AR__c,&quot;0 to 10 boxes&quot;),1,IF(ISPICKVAL(WeeklyBoxesVodkaFernetRon_AR__c,&quot;10 to 30 boxes&quot;),2,IF(ISPICKVAL(WeeklyBoxesVodkaFernetRon_AR__c,&quot;30 to 50 boxes&quot;),3,4)))*(10/81) ) / 2.7037037037037 )&gt; 0.8 ,1, 

IF( 
 ( (IF(ISPICKVAL(OwnParking_AR__c, &quot;YES&quot;),1,0)*(8/81)+

IF(ISPICKVAL(Capacity_AR__c,&quot;100 to 350&quot;),1,IF(ISPICKVAL(Capacity_AR__c,&quot;351 to 800&quot;),2,3))*(9/81)+

IF(ISPICKVAL(NumberDanceFloors_AR__c,&quot;1 Dance Floor&quot;),1,IF(ISPICKVAL(NumberDanceFloors_AR__c,&quot;2 Dance Floors&quot;),2,3))*(8/81)+

IF(ISPICKVAL(NumberCounters_AR__c,&quot;1 Counter&quot;),1,IF(ISPICKVAL(NumberCounters_AR__c,&quot;2 Counters&quot;),2,IF(ISPICKVAL(NumberCounters_AR__c,&quot;3 Counters&quot;),3,4)))*(10/81)+

IF(ISPICKVAL(AccessPrice_AR__c,&quot;30 to 80&quot;),1,IF(ISPICKVAL(AccessPrice_AR__c,&quot;80 to 150&quot;),2,3))*(7/81)+

IF(ISPICKVAL(AcceptsCreditCardWhichOnes_AR__c, &quot;YES&quot;),1,0)*(6/81)+

IF(ISPICKVAL(Dinner_AR__c, &quot;YES&quot;),1,0)*(7/81)+

IF(ISPICKVAL(WeeklyBoxesSparklingChamp_AR__c,&quot;0 to 50 boxes&quot;),1,IF(ISPICKVAL(WeeklyBoxesSparklingChamp_AR__c,&quot;50 to 150 boxes&quot;),2,IF(ISPICKVAL(WeeklyBoxesSparklingChamp_AR__c,&quot;150 to 250 boxes&quot;),3,4)))*(10/81)+

IF(ISPICKVAL(OutdoorArea_AR__c, &quot;YES&quot;),1,0)*(6/81) +

IF(ISPICKVAL(WeeklyBoxesVodkaFernetRon_AR__c,&quot;0 to 10 boxes&quot;),1,IF(ISPICKVAL(WeeklyBoxesVodkaFernetRon_AR__c,&quot;10 to 30 boxes&quot;),2,IF(ISPICKVAL(WeeklyBoxesVodkaFernetRon_AR__c,&quot;30 to 50 boxes&quot;),3,4)))*(10/81) ) / 2.7037037037037) &gt; 0.5 ,2, 3) )</formula>
        <name>SRV_UpdateProductivity3_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SRV_UpdateProductivity4_AR</fullName>
        <field>Productivity_AR__c</field>
        <formula>IF(
((IF(ISPICKVAL(ExcecutMenu_AR__c, &quot;YES&quot;),1,0)*(6/111)
+
IF(ISPICKVAL(Delivery_AR__c, &quot;YES&quot;),1,0)*(6/111)
+
IF(ISPICKVAL(OutdoorArea_AR__c, &quot;YES&quot;),1,0)*(7/111)
+
IF(ISPICKVAL(OwnParking_AR__c, &quot;YES&quot;),1,0)*(8/111)
+
IF(ISPICKVAL(AcceptsCreditCardWhichOnes_AR__c, &quot;YES&quot;),1,0)*(6/111)
+
IF(ISPICKVAL(AverageDaySale_AR__c ,&quot;50 to 100&quot;),1,IF(ISPICKVAL(AverageDaySale_AR__c ,&quot;101 to 150&quot;),2,3))*(8/111)
+
IF(ISPICKVAL(AverageNigthSale_AR__c,&quot;80 to 100&quot;),1,IF(ISPICKVAL(AverageNigthSale_AR__c,&quot;101 to 150&quot;),2,IF(ISPICKVAL(AverageNigthSale_AR__c,&quot;151 to 200&quot;),3,4)))*(10/111)
+
IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;0 to 10 boxes&quot;),1,IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;10 to 20 boxes&quot;),2,IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;20 to 30 boxes&quot;),3,4)))*(10/111)
+
IF(ISPICKVAL(QtyDailyMeals_AR__c,&quot;up to 30&quot;),1,IF(ISPICKVAL(QtyDailyMeals_AR__c,&quot;31 to 50&quot;),2,IF(ISPICKVAL(QtyDailyMeals_AR__c,&quot;51 to 100&quot;),3,4)))*(8/111)
+
IF(ISPICKVAL(QtyNightlyMeals_AR__c,&quot;up to 30&quot;),1,IF(ISPICKVAL(QtyNightlyMeals_AR__c,&quot;31 to 50&quot;),2,IF(ISPICKVAL(QtyNightlyMeals_AR__c,&quot;51 to 100&quot;),3,4)))*(10/111)
+
IF(ISPICKVAL(WiFi_AR__c, &quot;YES&quot;),1,0)*(3/111)
+
IF(ISPICKVAL(EventsandCatering_AR__c, &quot;YES&quot;),1,0)*(4/111)
+
IF(ISPICKVAL(Winebyglass_AR__c, &quot;YES&quot;),1,0)*(6/111)
+
IF(ISPICKVAL(DrinksMenu_AR__c, &quot;YES&quot;),1,0)*(8/111)
+
IF(ISPICKVAL(BenefitsClub_AR__c, &quot;YES&quot;),1,0)*(7/111)
+
IF(ISPICKVAL(HouseWineWhich_AR__c, &quot;YES&quot;),1,0)*(4/111)) /2.01) &gt; 0.8,
 1, IF(
((IF(ISPICKVAL(ExcecutMenu_AR__c, &quot;YES&quot;),1,0)*(6/111)
+
IF(ISPICKVAL(Delivery_AR__c, &quot;YES&quot;),1,0)*(6/111)
+
IF(ISPICKVAL(OutdoorArea_AR__c, &quot;YES&quot;),1,0)*(7/111)
+
IF(ISPICKVAL(OwnParking_AR__c, &quot;YES&quot;),1,0)*(8/111)
+
IF(ISPICKVAL(AcceptsCreditCardWhichOnes_AR__c, &quot;YES&quot;),1,0)*(6/111)
+
IF(ISPICKVAL(AverageDaySale_AR__c ,&quot;50 to 100&quot;),1,IF(ISPICKVAL(AverageDaySale_AR__c ,&quot;101 to 150&quot;),2,3))*(8/111)
+
IF(ISPICKVAL(AverageNigthSale_AR__c,&quot;80 to 100&quot;),1,IF(ISPICKVAL(AverageNigthSale_AR__c,&quot;101 to 150&quot;),2,IF(ISPICKVAL(AverageNigthSale_AR__c,&quot;151 to 200&quot;),3,4)))*(10/111)
+
IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;0 to 10 boxes&quot;),1,IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;10 to 20 boxes&quot;),2,IF(ISPICKVAL(WeeklyWineSparkChampg_AR__c,&quot;20 to 30 boxes&quot;),3,4)))*(10/111)
+
IF(ISPICKVAL(QtyDailyMeals_AR__c,&quot;up to 30&quot;),1,IF(ISPICKVAL(QtyDailyMeals_AR__c,&quot;31 to 50&quot;),2,IF(ISPICKVAL(QtyDailyMeals_AR__c,&quot;51 to 100&quot;),3,4)))*(8/111)
+
IF(ISPICKVAL(QtyNightlyMeals_AR__c,&quot;up to 30&quot;),1,IF(ISPICKVAL(QtyNightlyMeals_AR__c,&quot;31 to 50&quot;),2,IF(ISPICKVAL(QtyNightlyMeals_AR__c,&quot;51 to 100&quot;),3,4)))*(10/111)
+
IF(ISPICKVAL(WiFi_AR__c, &quot;YES&quot;),1,0)*(3/111)
+
IF(ISPICKVAL(EventsandCatering_AR__c, &quot;YES&quot;),1,0)*(4/111)
+
IF(ISPICKVAL(Winebyglass_AR__c, &quot;YES&quot;),1,0)*(6/111)
+
IF(ISPICKVAL(DrinksMenu_AR__c, &quot;YES&quot;),1,0)*(8/111)
+
IF(ISPICKVAL(BenefitsClub_AR__c, &quot;YES&quot;),1,0)*(7/111)
+
IF(ISPICKVAL(HouseWineWhich_AR__c, &quot;YES&quot;),1,0)*(4/111*100))/2.01) &gt; 0.5, 2, 3))</formula>
        <name>SRV_UpdateProductivity4_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SRV_UpdateProductivity5_AR</fullName>
        <field>Productivity_AR__c</field>
        <formula>IF(
((IF(ISPICKVAL(Capacity_AR__c,&quot;0 to 50&quot;),1,IF(ISPICKVAL(Capacity_AR__c,&quot;51 to 150&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(SmokingArea_AR__c, &quot;YES&quot;),1,0)*(7/93)
+
IF(ISPICKVAL(OutdoorArea_AR__c, &quot;YES&quot;),1,0)*(6/93)
+
IF(ISPICKVAL(AverageTicket_AR__c,&quot;50 to 100&quot;),1,IF(ISPICKVAL(AverageTicket_AR__c,&quot;101 to 150&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(OffersFood_AR__c, &quot;YES&quot;),1,0)*(4/93)
+
IF(ISPICKVAL(BenefitsClub_AR__c, &quot;YES&quot;),1,0)*(7/93)
+
IF(ISPICKVAL(AfterOffice_AR__c, &quot;YES&quot;),1,0)*(7/93)
+
IF(ISPICKVAL(NumberBottlesCounter_AR__c,&quot;0-30&quot;),1,IF(ISPICKVAL(NumberBottlesCounter_AR__c,&quot;30-60&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(AverageAmountPerson_AR__c,&quot;1 Drink&quot;),1,IF(ISPICKVAL(AverageAmountPerson_AR__c,&quot;2 Drinks&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(WeeklyBoxesWhiskysVodkasFernet_AR__c,&quot;0 to 5 boxes&quot;),1,IF(ISPICKVAL(WeeklyBoxesWhiskysVodkasFernet_AR__c,&quot;5 to 10 boxes&quot;),2,IF(ISPICKVAL(WeeklyBoxesWhiskysVodkasFernet_AR__c,&quot;10 to 20 boxes&quot;),3,4)))*(10/93)
+
IF(ISPICKVAL(HappyHours_AR__c, &quot;YES&quot;),1,0)*(5/93)
+
IF(ISPICKVAL(HoursOpen_AR__c,&quot;0 - 4hs&quot;),1,IF(ISPICKVAL(HoursOpen_AR__c,&quot;4 - 8hs&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(AcceptsCreditCardWhichOnes_AR__c, &quot;YES&quot;),1,0)*(6/93)) / 2.20430107526882) &gt; 0.8, 1, 
 IF(
((IF(ISPICKVAL(Capacity_AR__c,&quot;0 to 50&quot;),1,IF(ISPICKVAL(Capacity_AR__c,&quot;51 to 150&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(SmokingArea_AR__c, &quot;YES&quot;),1,0)*(7/93)
+
IF(ISPICKVAL(OutdoorArea_AR__c, &quot;YES&quot;),1,0)*(6/93)
+
IF(ISPICKVAL(AverageTicket_AR__c,&quot;50 to 100&quot;),1,IF(ISPICKVAL(AverageTicket_AR__c,&quot;101 to 150&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(OffersFood_AR__c, &quot;YES&quot;),1,0)*(4/93)
+
IF(ISPICKVAL(BenefitsClub_AR__c, &quot;YES&quot;),1,0)*(7/93)
+
IF(ISPICKVAL(AfterOffice_AR__c, &quot;YES&quot;),1,0)*(7/93)
+
IF(ISPICKVAL(NumberBottlesCounter_AR__c,&quot;0-30&quot;),1,IF(ISPICKVAL(NumberBottlesCounter_AR__c,&quot;30-60&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(AverageAmountPerson_AR__c,&quot;1 Drink&quot;),1,IF(ISPICKVAL(AverageAmountPerson_AR__c,&quot;2 Drinks&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(WeeklyBoxesWhiskysVodkasFernet_AR__c,&quot;0 to 5 boxes&quot;),1,IF(ISPICKVAL(WeeklyBoxesWhiskysVodkasFernet_AR__c,&quot;5 to 10 boxes&quot;),2,IF(ISPICKVAL(WeeklyBoxesWhiskysVodkasFernet_AR__c,&quot;10 to 20 boxes&quot;),3,4)))*(10/93)
+
IF(ISPICKVAL(HappyHours_AR__c, &quot;YES&quot;),1,0)*(5/93)
+
IF(ISPICKVAL(HoursOpen_AR__c,&quot;0 - 4hs&quot;),1,IF(ISPICKVAL(HoursOpen_AR__c,&quot;4 - 8hs&quot;),2,3))*(10/93)
+
IF(ISPICKVAL(AcceptsCreditCardWhichOnes_AR__c, &quot;YES&quot;),1,0)*(6/93)) / 2.20430107526882) &gt; 0.5, 2, 3) )</formula>
        <name>SRV_UpdateProductivity5_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>SRV_WF01_ImpactRestourant_AR</fullName>
        <actions>
            <name>SRV_UpdateImpact_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>% IMPACTO =  TOTAL IMPACTO / Max Ponderado de total de impacto</description>
        <formula>$RecordType.DeveloperName=&apos;SRV_3_Restaurant_AR&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SRV_WF02_ImpactBar_ARG</fullName>
        <actions>
            <name>SRV_UpdateImpact2_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>% IMPACTO = TOTAL IMPACTO / Max Ponderado de total de impacto</description>
        <formula>$RecordType.DeveloperName = &apos;SRV_1_Bar_AR&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SRV_WF03_ImpactDisco_AR</fullName>
        <actions>
            <name>SRV_UpdateImpact3_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>% IMPACTO = TOTAL IMPACTO / Max Ponderado de total de impacto</description>
        <formula>$RecordType.DeveloperName=&apos;SRV_2_Disco_AR&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SRV_WF04_ProductivityRestoran_AR</fullName>
        <actions>
            <name>SRV_UpdateProductivity4_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>% Productividad =  TOTAL Productividad / Max Ponderado de total de Productividad</description>
        <formula>$RecordType.DeveloperName=&apos;SRV_3_Restaurant_AR&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SRV_WF05_ProductivityBAr_AR</fullName>
        <actions>
            <name>SRV_UpdateProductivity5_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>% Productividad =  TOTAL Productividad / Max Ponderado de total de Productividad</description>
        <formula>$RecordType.DeveloperName = &apos;SRV_1_Bar_AR&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SRV_WF06_ProductivityDisco_AR</fullName>
        <actions>
            <name>SRV_UpdateProductivity3_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>% Productividad =  TOTAL Productividad / Max Ponderado de total de Productividad</description>
        <formula>$RecordType.DeveloperName=&apos;SRV_2_Disco_AR&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SVR_WF07_Rating_segmentation_AR</fullName>
        <actions>
            <name>SRV_UpdateProductivity114_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rating segmentation. (Impact + Productivity)</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
