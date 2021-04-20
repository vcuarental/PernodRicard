<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_HK_CustMap_FieldUpdate</fullName>
        <field>ASI_CRM_External_ID__c</field>
        <formula>&quot;HK_CUST_&quot; +  ASI_CRM_Account__r.ASI_HK_CRM_Customer_Code__c + &quot;_&quot; +  ASI_CRM_Buyer_ID__c</formula>
        <name>ASI_CRM_HK_CustMap_FieldUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_CustMappingExtID_Update</fullName>
        <field>ASI_CRM_External_ID__c</field>
        <formula>ASI_CRM_Wholesaler__r.ASI_CRM_MY_CustomerCode__c + &quot;_&quot; +  ASI_CRM_Offtake_Customer_No__c</formula>
        <name>ASI_CRM_SG_CustMappingExtID_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_HK_Customer_Mapping_ExtID</fullName>
        <actions>
            <name>ASI_CRM_HK_CustMap_FieldUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Customer_Mapping__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CRM HK EDI Customer Mapping</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_SG_CustomerMappingExtID</fullName>
        <actions>
            <name>ASI_CRM_SG_CustMappingExtID_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Customer_Mapping__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG Customer Mapping</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
