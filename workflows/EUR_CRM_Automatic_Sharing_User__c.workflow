<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_AS_Set_To_Waiting_for_batch</fullName>
        <field>EUR_CRM_Status__c</field>
        <literalValue>Waiting for batch</literalValue>
        <name>EUR AS Set To Waiting for batch</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>EUR_CRM_AS__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>EUR New Update ASU</fullName>
        <actions>
            <name>EUR_AS_Set_To_Waiting_for_batch</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Mark automatically the AS to &quot;Waiting for batch&quot; if a ASU is created/Updated.</description>
        <formula>NOT( ISPICKVAL( EUR_CRM_AS__r.EUR_CRM_Status__c , &apos;Draft&apos;) ||  ISPICKVAL( EUR_CRM_AS__r.EUR_CRM_Status__c , &apos;To be deleted&apos;) )  &amp;&amp;  ( ISNEW()  ||  (NOT(ISNEW()) &amp;&amp;  (TEXT(PRIORVALUE( EUR_CRM_Access_Level__c)) != TEXT(EUR_CRM_Access_Level__c) || EUR_CRM_To_be_Deleted__c != PRIORVALUE(EUR_CRM_To_be_Deleted__c) ) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
