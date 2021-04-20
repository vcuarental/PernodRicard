<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BMC_RF_Asset_Hardware_Rental_Notification_English</fullName>
        <description>BMC_RF_Asset Hardware Rental Notification (English)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__PrimaryClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__SupportedBy__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Asset_Hardware_Rental_Notif_Eng</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Asset_Hardware_Rental_Notification_French</fullName>
        <description>BMC_RF_Asset Hardware Rental Notification (French)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__PrimaryClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__SupportedBy__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Asset_Hardware_Rental_Notif_Fr</template>
    </alerts>
    <fieldUpdates>
        <fullName>BMCServiceDesk__ChangeStatustoDecommissioned</fullName>
        <description>When Mark As Deleted changes from false to true, change the CI Status to Decommissioned.</description>
        <field>BMCServiceDesk__CI_Status__c</field>
        <literalValue>Decommissioned</literalValue>
        <name>Change Status to Decommissioned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__ChangeStatustoDeployed</fullName>
        <description>When the Mark As Deleted changes from true to false, change the status to Deployed.</description>
        <field>BMCServiceDesk__CI_Status__c</field>
        <literalValue>Deployed</literalValue>
        <name>Change Status to Deployed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BMCServiceDesk__BMC Discovery - Change CI Status When Mark As Deleted is Checked</fullName>
        <actions>
            <name>BMCServiceDesk__ChangeStatustoDecommissioned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>BMCServiceDesk__BMC_BaseElement__c.BMCServiceDesk__Source__c</field>
            <operation>equals</operation>
            <value>BMC Discovery</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__BMC_BaseElement__c.BMCServiceDesk__MarkAsDeleted__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>For instances imported from BMC Discovery, when Mark As Deleted changes from false to true, change the CI Status to Decommissioned.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__BMC Discovery - Change CI Status When Mark As Deleted is Unchecked</fullName>
        <actions>
            <name>BMCServiceDesk__ChangeStatustoDeployed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>BMCServiceDesk__BMC_BaseElement__c.BMCServiceDesk__Source__c</field>
            <operation>equals</operation>
            <value>BMC Discovery</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__BMC_BaseElement__c.BMCServiceDesk__MarkAsDeleted__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>For instances imported from BMC Discovery, when instance is Mark as Deleted from true to false, Update CI Status to Deployed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Change CI Status When Mark As Deleted is Checked</fullName>
        <actions>
            <name>BMCServiceDesk__ChangeStatustoDecommissioned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>BMCServiceDesk__BMC_BaseElement__c.BMCServiceDesk__Source__c</field>
            <operation>equals</operation>
            <value>BMC Discovery</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__BMC_BaseElement__c.BMCServiceDesk__MarkAsDeleted__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When Mark As Deleted changes from false to true, change the CI Status to Decommissioned.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Change CI Status When Mark As Deleted is Unchecked</fullName>
        <actions>
            <name>BMCServiceDesk__ChangeStatustoDeployed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>BMCServiceDesk__BMC_BaseElement__c.BMCServiceDesk__Source__c</field>
            <operation>equals</operation>
            <value>BMC Discovery</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__BMC_BaseElement__c.BMCServiceDesk__MarkAsDeleted__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>When instance is Mark as Deleted from true to false, Update CI Status to Deployed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
