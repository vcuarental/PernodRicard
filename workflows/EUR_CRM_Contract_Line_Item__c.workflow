<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_CRM_ContractLineItem_Total_FUpdate</fullName>
        <description>Update Total Value Reference (Total Value - Formula)</description>
        <field>EUR_CRM_Total_Value_Reference__c</field>
        <formula>EUR_CRM_Total_Value__c</formula>
        <name>EUR CRM ContractLineItem Total FUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR CRM ContractLineItem Total Value</fullName>
        <actions>
            <name>EUR_CRM_ContractLineItem_Total_FUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Contract_Line_Item__c.EUR_CRM_Value__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Contract_Line_Item__c.EUR_CRM_TotalSpend__c</field>
            <operation>notEqual</operation>
            <value>EUR 0</value>
        </criteriaItems>
        <description>Copy Total Value (Formula) to Total Value Reference (Number), for  roll-up summary</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
