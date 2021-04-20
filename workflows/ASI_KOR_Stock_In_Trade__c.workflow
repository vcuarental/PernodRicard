<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_KOR_SIT_Change_RecordType_Editable</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_KOR_SIT_Editable</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI KOR SIT Change RecordType - Editable</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_KOR_SIT_Change_RecordType_to_Locked</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_KOR_SIT_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI KOR SIT Change RecordType to Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_KOR_Stock_in_Trade_ID</fullName>
        <field>ASI_KOR_Sys_Stock_in_trade_header_ID__c</field>
        <formula>ASI_KOR_Year__c  &amp; &quot;_&quot; &amp;   TEXT(ASI_KOR_Month__c) &amp; &quot;_&quot; &amp; ASI_KOR_Wholesaler__r.ASI_KOR_Customer_Code__c</formula>
        <name>ASI_KOR_Stock in Trade ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI KOR Lock Stock In Trade Entry</fullName>
        <actions>
            <name>ASI_KOR_SIT_Change_RecordType_to_Locked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_Stock_In_Trade__c.ASI_KOR_Status__c</field>
            <operation>equals</operation>
            <value>Locked</value>
        </criteriaItems>
        <description>Lock Stock in Trade Entry and Detail objects if status is Locked</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI KOR Unlock Stock In Trade Entry</fullName>
        <actions>
            <name>ASI_KOR_SIT_Change_RecordType_Editable</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_Stock_In_Trade__c.ASI_KOR_Status__c</field>
            <operation>equals</operation>
            <value>Editable</value>
        </criteriaItems>
        <description>Unlock Stock in Trade Entry and Detail objects if status is Editable</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_KOR_Stock in Trade ID</fullName>
        <actions>
            <name>ASI_KOR_Stock_in_Trade_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED( ASI_KOR_Year__c ) || ISCHANGED( ASI_KOR_Month__c ) || ISCHANGED(  ASI_KOR_Wholesaler__c ) || ISCHANGED( ASI_KOR_Sys_Stock_in_trade_header_ID__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
