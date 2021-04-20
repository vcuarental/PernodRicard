<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>gvp__Update_Item_Price</fullName>
        <field>gvp__Price__c</field>
        <formula>CASE( gvp__Price_Level_Native__c ,
&quot;Level 2&quot;,  gvp__Item__r.gvp__Price_Level_2__c,
&quot;Level 3&quot;,  gvp__Item__r.gvp__Price_Level_3__c,
&quot;Level 4&quot;,  gvp__Item__r.gvp__Price_Level_4__c,
&quot;Level 5&quot;,  gvp__Item__r.gvp__Price_Level_5__c,
gvp__Item__r.gvp__Price_List__c)</formula>
        <name>Update Item Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>true</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>gvp__Check Pricing Level</fullName>
        <actions>
            <name>gvp__Update_Item_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>gvp__Sales_Order_Item__c.gvp__Price_Level_Native__c</field>
            <operation>notEqual</operation>
            <value>Custom</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
