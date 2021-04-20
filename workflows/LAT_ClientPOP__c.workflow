<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Date_Update</fullName>
        <field>Delivered_Date__c</field>
        <formula>IF(ISNULL(Planned_Date__c),  TODAY() , Planned_Date__c)</formula>
        <name>Date Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_UPDATE_DATE</fullName>
        <field>Delivered_Date__c</field>
        <formula>TODAY()</formula>
        <name>LAT_UPDATE_DATE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_UPDATE_Planned</fullName>
        <field>LAT_Planned__c</field>
        <formula>0</formula>
        <name>LAT_UPDATE_Planned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LAT_Validate_Delivered</fullName>
        <actions>
            <name>Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>LAT_UPDATE_Planned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Delivered__c)  &amp;&amp;  ISNULL(Delivered_Date__c) &amp;&amp; ! isNULL(Delivered__c) &amp;&amp; (isNULL(PRIORVALUE(Delivered__c)) || PRIORVALUE(Delivered__c) == 0)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
