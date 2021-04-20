<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AprovacionRFC</fullName>
        <field>status__c</field>
        <literalValue>Aprobado</literalValue>
        <name>AprovacionRFC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updateRFCStatus</fullName>
        <field>status__c</field>
        <literalValue>Aprobado</literalValue>
        <name>updateRFCStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LAT_MX_AprovacionRFC</fullName>
        <actions>
            <name>AprovacionRFC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>MX - Gerente de Administracion de Ventas</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
