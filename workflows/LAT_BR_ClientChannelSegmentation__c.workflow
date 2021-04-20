<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LAT_BR_CCS_UpdateStatus1</fullName>
        <description>Updates field &quot;BR Approval Status&quot; to &quot;Manager approval&quot;.</description>
        <field>LAT_BR_ApprovalStatus__c</field>
        <literalValue>Manager approval</literalValue>
        <name>LAT_BR_CCS_UpdateStatus1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CCS_UpdateStatus2</fullName>
        <description>Updates field &quot;BR Approval Status&quot; to &quot;Area Manager approval&quot;.</description>
        <field>LAT_BR_ApprovalStatus__c</field>
        <literalValue>Area Manager approval</literalValue>
        <name>LAT_BR_CCS_UpdateStatus2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CCS_UpdateStatus3</fullName>
        <description>Updates field &quot;BR Approval Status&quot; to &quot;Regional Manager approval&quot;.</description>
        <field>LAT_BR_ApprovalStatus__c</field>
        <literalValue>Regional Manager approval</literalValue>
        <name>LAT_BR_CCS_UpdateStatus3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CCS_UpdateStatus4</fullName>
        <description>Updates field &quot;BR Approval Status&quot; to &quot;On Management approval&quot;.</description>
        <field>LAT_BR_ApprovalStatus__c</field>
        <literalValue>On Management approval</literalValue>
        <name>LAT_BR_CCS_UpdateStatus4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CCS_UpdateStatus5</fullName>
        <description>Updates field &quot;BR Approval Status&quot; to &quot;Commercial Development approval&quot;.</description>
        <field>LAT_BR_ApprovalStatus__c</field>
        <literalValue>Commercial Development approval</literalValue>
        <name>LAT_BR_CCS_UpdateStatus5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CCS_UpdateStatus6</fullName>
        <description>Updates field &quot;BR Approval Status&quot; to &quot;Commercial Director approval&quot;.</description>
        <field>LAT_BR_ApprovalStatus__c</field>
        <literalValue>Commercial Director approval</literalValue>
        <name>LAT_BR_CCS_UpdateStatus6</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CCS_UpdateStatus7</fullName>
        <description>Updates field &quot;BR Approval Status&quot; to &quot;Controladoria approval&quot;.</description>
        <field>LAT_BR_ApprovalStatus__c</field>
        <literalValue>Controladoria approval</literalValue>
        <name>LAT_BR_CCS_UpdateStatus7</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CCS_UpdateStatus8</fullName>
        <description>Updates field &quot;BR Approval Status&quot; to &quot;Active&quot;.</description>
        <field>LAT_BR_ApprovalStatus__c</field>
        <literalValue>Active</literalValue>
        <name>LAT_BR_CCS_UpdateStatus8</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CCS_UpdateStatus9</fullName>
        <description>Updates field &quot;BR Approval Status&quot; to &quot;Rejectedl&quot;.</description>
        <field>LAT_BR_ApprovalStatus__c</field>
        <literalValue>Rejected</literalValue>
        <name>LAT_BR_CCS_UpdateStatus9</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_UpdatesRatingPotentialClient</fullName>
        <field>Rating</field>
        <literalValue>Cliente potencial</literalValue>
        <name>LAT_BR_UpdatesRatingPotentialClient</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>LAT_BR_Client__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>LAT_BR_CSS_UpdatesClientRating</fullName>
        <actions>
            <name>LAT_BR_UpdatesRatingPotentialClient</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$RecordType.DeveloperName=&quot;LAT_BR_CCS_OnTrade&quot; &amp;&amp; NOT(ISPICKVAL( LAT_BR_MainBillFocus__c, &quot;&quot;)) &amp;&amp; NOT(ISPICKVAL(LAT_BR_MainConsumptionOccasion__c, &quot;&quot;)) &amp;&amp; NOT(ISPICKVAL(LAT_BR_PubPhysicalSpace__c, &quot;&quot;)) &amp;&amp; NOT(ISPICKVAL(LAT_BR_ActivitiesStartTime__c, &quot;&quot;)) &amp;&amp; NOT(ISPICKVAL(LAT_BR_Music__c, &quot;&quot;)) &amp;&amp; NOT(ISPICKVAL(LAT_BR_MainBrandsSold__c, &quot;&quot;)) &amp;&amp; NOT(ISPICKVAL(LAT_BR_ConsumerProfile__c, &quot;&quot;)) &amp;&amp; NOT(ISPICKVAL(LAT_BR_Brigade__c, &quot;&quot;)) &amp;&amp; NOT(ISPICKVAL(LAT_BR_MainDrinks__c, &quot;&quot;)) &amp;&amp; NOT(ISPICKVAL(LAT_BR_AverageSodaCansPrice__c, &quot;&quot;)) &amp;&amp; NOT(ISPICKVAL(LAT_BR_AverageMainMealPrice__c, &quot;&quot;)) &amp;&amp; NOT(ISPICKVAL(LAT_BR_PeopleCapacity__c, &quot;&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
