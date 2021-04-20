<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AME_Set_Problem_Number_on_Incident</fullName>
        <field>BMC_RF_Problem__c</field>
        <formula>BMCServiceDesk__FKProblem__r.Name</formula>
        <name>AME Set Problem Number on Incident</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>BMCServiceDesk__FKIncident__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>AME Set Problem Number on Incident</fullName>
        <actions>
            <name>AME_Set_Problem_Number_on_Incident</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Problem__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
