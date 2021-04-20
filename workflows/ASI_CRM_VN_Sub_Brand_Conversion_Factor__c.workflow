<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Set_External_Id</fullName>
        <field>ASI_CRM_VN_External_Id__c</field>
        <formula>RecordType.DeveloperName+&apos;_&apos;+ ASI_CRM_VN_Sub_brand_From__r.ASI_MFM_Sub_brand_Code__c+&apos;_&apos;+ASI_CRM_VN_Sub_brand_To__r.ASI_MFM_Sub_brand_Code__c</formula>
        <name>ASI CRM VN Set External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI CRM VN Set External Id</fullName>
        <actions>
            <name>ASI_CRM_VN_Set_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR ( ISCHANGED( ASI_CRM_VN_Sub_brand_From__c ) ,  ISCHANGED( ASI_CRM_VN_Sub_brand_To__c ), ISNEW() )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
