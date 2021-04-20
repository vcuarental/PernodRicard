<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PRH_Iconic_Account_Created_Email</fullName>
        <description>PRH Iconic Account Created Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>anais.cherpin@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/PRH_Iconic_Account_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>PRH_Iconic_Account_Suppress_Notification</fullName>
        <ccEmails>lecercleapp@pernod-ricard.com</ccEmails>
        <description>PRH Iconic Account Suppress Notification</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/PRH_Iconic_Account_Notification_For_Deletion</template>
    </alerts>
    <fieldUpdates>
        <fullName>PRH_High_Energy_Bars_to_High_Energy_Bar</fullName>
        <field>PRH_Account_Type__c</field>
        <literalValue>High Energy Bar</literalValue>
        <name>PRH High Energy Bars to High Energy Bar</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PRH_Low_Energy_Bars_to_Low_Energy_Bar</fullName>
        <field>PRH_Account_Type__c</field>
        <literalValue>Low Energy Bar</literalValue>
        <name>PRH Low Energy Bars to Low Energy Bar</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PRH Iconic Account Creation Notification</fullName>
        <actions>
            <name>PRH_Iconic_Account_Created_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PRH_Luxury_Accounts__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Luxury Account</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PRH Iconic Account Suppress Notification</fullName>
        <actions>
            <name>PRH_Iconic_Account_Suppress_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PRH_Luxury_Accounts__c.PRH_Suppress_and_archive__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Notification du support Le Cercle lorsqu&apos;un Iconic Account est passé à l&apos;état Suppress</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PRH Set Account Type - HEB</fullName>
        <actions>
            <name>PRH_High_Energy_Bars_to_High_Energy_Bar</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ispickval(PRH_Account_Type__c, &quot;High Energy Bars&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PRH Set Account Type - LEB</fullName>
        <actions>
            <name>PRH_Low_Energy_Bars_to_Low_Energy_Bar</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ispickval(PRH_Account_Type__c, &quot;Low Energy Bars&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
