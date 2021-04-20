<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Copia_SKU_Produto</fullName>
        <field>LAT_ProductCode__c</field>
        <formula>LAT_Sku__c</formula>
        <name>Copia SKU Produto</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_Update_Bottles_Per_Pallet</fullName>
        <field>LAT_BottlesPerPallet__c</field>
        <formula>LAT_BoxesPerPallet__c * LAT_BottlesPerBox__c</formula>
        <name>Update Bottles Per Pallet</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LAT_SetBottlesPerPallet</fullName>
        <actions>
            <name>LAT_Update_Bottles_Per_Pallet</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Popultates de Bottles per Pallet Field</description>
        <formula>AND( NOT(ISNULL( LAT_BoxesPerPallet__c )),  NOT(ISNULL( LAT_BottlesPerBox__c)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Sync SKU Produto</fullName>
        <actions>
            <name>Copia_SKU_Produto</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copia o campo SKU para o campo código do produto (default).</description>
        <formula>LAT_Sku__c &lt;&gt; LAT_ProductCode__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
