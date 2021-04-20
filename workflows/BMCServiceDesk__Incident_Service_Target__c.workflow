<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Update_SLA_Target_Date</fullName>
        <field>BMC_RF_Target_End_Date__c</field>
        <formula>BMCServiceDesk__TargetEndDate__c</formula>
        <name>BMC_RF_Incident Update SLA Target Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>BMCServiceDesk__FKIncident__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>BMC_RF_Incident Update SLA Target Date</fullName>
        <actions>
            <name>BMC_RF_Incident_Update_SLA_Target_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNULL(BMCServiceDesk__TargetEndDate__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
