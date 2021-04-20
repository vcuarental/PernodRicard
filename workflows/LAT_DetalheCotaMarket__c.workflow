<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>updateDateConsumida</fullName>
        <field>dateConsumida__c</field>
        <formula>TODAY()</formula>
        <name>updateDateConsumida</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>updateDateConsumida</fullName>
        <actions>
            <name>updateDateConsumida</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISNEW() || (PRIORVALUE(cantidadDisponible__c) &gt; 0 &amp;&amp;  ISCHANGED(cantidadDisponible__c)))&amp;&amp;  cantidadDisponible__c &lt;= 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
