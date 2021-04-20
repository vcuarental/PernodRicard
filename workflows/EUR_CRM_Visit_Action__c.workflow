<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_CRM_Update_Visit_Action_Is_Accrued</fullName>
        <field>EUR_CRM_Is_Accrued__c</field>
        <literalValue>0</literalValue>
        <name>Update Visit Action Is Accrued</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR CRM DE Update Visit Action Is Accrued Flag</fullName>
        <actions>
            <name>EUR_CRM_Update_Visit_Action_Is_Accrued</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.DeveloperName == &apos;EUR_DE_OFF_2nd_PL_Sell_In_Qty_Theme&apos; &amp;&amp;  PRIORVALUE( EUR_CRM_Sell_In_Volume_Total_Bottles__c ) != EUR_CRM_Sell_In_Volume_Total_Bottles__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
