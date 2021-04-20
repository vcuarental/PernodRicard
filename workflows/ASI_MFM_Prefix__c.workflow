<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_MFM_KR_Set_Prefix_Name</fullName>
        <field>Name</field>
        <formula>ASI_MFM_Project_Code__r.ASI_MFM_Code__c + RIGHT(  TEXT(ASI_MFM_Fiscal_year__c ) , 1)</formula>
        <name>ASI MFM KR Set Prefix Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_MFM_KR_SetPrefixName</fullName>
        <actions>
            <name>ASI_MFM_KR_Set_Prefix_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_Prefix__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI MFM KR Prefix</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_Prefix__c.ASI_MFM_Module__c</field>
            <operation>equals</operation>
            <value>Plan</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_Prefix__c.ASI_MFM_Type__c</field>
            <operation>equals</operation>
            <value>Upload</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_Prefix__c.ASI_MFM_Fiscal_year__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
