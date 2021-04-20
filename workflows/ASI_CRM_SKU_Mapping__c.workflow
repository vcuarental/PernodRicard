<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_HK_EDI_SKU_Mapping_FieldUpdate</fullName>
        <field>ASI_CRM_SKU_Mapping_External_ID__c</field>
        <formula>IF( 
	RecordType.DeveloperName == &quot;ASI_CRM_HK_EDI_SKU_Mapping&quot;,
	&quot;HK_SKU_&quot; + ASI_CRM_Account__r.ASI_HK_CRM_Customer_Code__c  + &quot;_&quot; +  ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c + &quot;_&quot; +  ASI_CRM_Item_Number__c,
	&quot;HK_ITEM_&quot; + ASI_CRM_Account__r.ASI_HK_CRM_Customer_Code__c  + &quot;_&quot; +  ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c + &quot;_&quot; +  ASI_CRM_Item_Number__c
)</formula>
        <name>ASI_CRM_HK_EDI_SKU_Mapping_FieldUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_HK_EDI_SKU_Mapping_ExtID</fullName>
        <actions>
            <name>ASI_CRM_HK_EDI_SKU_Mapping_FieldUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_SKU_Mapping__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CRM HK EDI SKU Mapping,CRM HK EDI Item Group Mapping</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
