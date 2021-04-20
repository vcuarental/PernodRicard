<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_MY_Update_RecordType_ActualOffH</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_MY_Actual_Offtake_Header_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_CRM_MY_Update_RecordType_ActualOffH</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_MY_Update_Region_ActualOffHead</fullName>
        <field>ASI_CRM_Branch__c</field>
        <formula>ASI_CRM_ToOutlet__r.ASI_CRM_MY_Branch__c</formula>
        <name>ASI_CRM_MY_Update_Region_ActualOffHead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_MY_Update_RecordType_ActualOffH</fullName>
        <actions>
            <name>ASI_CRM_MY_Update_RecordType_ActualOffH</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_ActualOfftakeHeader__c.ASI_CRM_Status__c</field>
            <operation>equals</operation>
            <value>Final</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_ActualOfftakeHeader__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI CRM MY Actual Offtake Header</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_ActualOfftakeHeader__c.ASI_CRM_Calculated_Payment_Status__c</field>
            <operation>equals</operation>
            <value>Final</value>
        </criteriaItems>
        <description>Change to read only when Status is Final</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_MY_Update_Region_ActualOffHead</fullName>
        <actions>
            <name>ASI_CRM_MY_Update_Region_ActualOffHead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_ActualOfftakeHeader__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI CRM MY Actual Offtake Header</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
