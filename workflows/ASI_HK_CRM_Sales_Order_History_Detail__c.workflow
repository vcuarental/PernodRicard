<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_MY_Update_Region_SalesOrderHisto</fullName>
        <field>ASI_CRM_Branch__c</field>
        <formula>ASI_HK_CRM_Sales_Order_History__r.ASI_CRM_Branch__c</formula>
        <name>ASI_CRM_MY_Update_Region_SalesOrderHisto</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_MY_Update_Region_SalesOrderHistoryDetail</fullName>
        <actions>
            <name>ASI_CRM_MY_Update_Region_SalesOrderHisto</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Sales_Order_History_Detail__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>MY CRM Sales Order History Detail</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
