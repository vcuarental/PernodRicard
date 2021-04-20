<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Active_Flag_to_False</fullName>
        <field>EUR_CRM_Active__c</field>
        <literalValue>0</literalValue>
        <name>Set Active Flag to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>set_Active_Flag_to_True</fullName>
        <field>EUR_CRM_Active__c</field>
        <literalValue>1</literalValue>
        <name>set Active Flag to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Activate Competitor Contract Tracking %28EU%29</fullName>
        <actions>
            <name>set_Active_Flag_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Competitor Contract Tracking (EU) Active Flag to True</description>
        <formula>EUR_CRM_Contract_End_Date__c  &gt;= TODAY()</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Deactivate Competitor Contract Tracking %28EU%29</fullName>
        <actions>
            <name>Set_Active_Flag_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Competitor Contract Tracking (EU) Active Flag to False</description>
        <formula>EUR_CRM_Contract_End_Date__c  &lt; TODAY() || EUR_CRM_Contract_End_Date__c  == NULL</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
