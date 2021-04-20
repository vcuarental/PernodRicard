<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Copia_SKU_Produto</fullName>
        <field>ProductCode</field>
        <formula>SKU__c</formula>
        <name>Copia SKU Produto</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Sync SKU Produto</fullName>
        <actions>
            <name>Copia_SKU_Produto</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copia o campo SKU para o campo código do produto (default).</description>
        <formula>SKU__c &lt;&gt; ProductCode</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
