<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LAT_BR_YearSegmentationRegion_Concatena</fullName>
        <field>LAT_BR_YearSegmentationRegion__c</field>
        <formula>TEXT(LAT_BR_FiscalYear__c)  + &apos; &apos; + TEXT(LAT_BR_Segmentation__c)  + &apos; &apos; + 
TEXT(LAT_BR_Region__c)</formula>
        <name>LAT_BR_YearSegmentationRegion_Concatena</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LAT_BR_YearSegmentationRegion_Concatena</fullName>
        <actions>
            <name>LAT_BR_YearSegmentationRegion_Concatena</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
