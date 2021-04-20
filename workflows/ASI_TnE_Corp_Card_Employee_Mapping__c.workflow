<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_eForm_KR_PopulateEnhancedLookup</fullName>
        <field>ASI_eForm_Sys_Enhanced_Lookup_Search__c</field>
        <formula>ASI_TnE_Employee_Name__r.LastName + ASI_TnE_Employee_Name__r.FirstName +  ASI_TnE_Card_Number_1__c</formula>
        <name>ASI_eForm_KR_PopulateEnhancedLookup</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_eForm_KR_PopulateEnhancedLookup</fullName>
        <actions>
            <name>ASI_eForm_KR_PopulateEnhancedLookup</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_TnE_Corp_Card_Employee_Mapping__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>TnE KR Corp Card Employee Mapping</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
