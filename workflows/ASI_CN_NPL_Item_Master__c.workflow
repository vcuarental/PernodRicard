<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CN_NPL_Item_Master_Alert_Type_A_Completed</fullName>
        <description>ASI CN NPL Item Master Alert Type A Completed</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_NPL_Item_Master_Alert_Type_A_Comp</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CN_NPL_Email_Template/ASI_CN_NPL_Item_Master_Complete_VF</template>
    </alerts>
    <alerts>
        <fullName>ASI_CN_NPL_Item_Master_Alert_Type_B_Completed</fullName>
        <description>ASI CN NPL Item Master Alert Type B Completed</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_NPL_Item_Master_Alert_Type_B_Comp</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CN_NPL_Email_Template/ASI_CN_NPL_Item_Master_Complete_VF</template>
    </alerts>
    <alerts>
        <fullName>ASI_CN_NPL_Item_Master_Alert_to_BA</fullName>
        <description>ASI CN NPL Item Master Alert to BA</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_NPL_Item_Master_Alert_to_BA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CN_NPL_Email_Template/ASI_CN_NPL_Item_Master_BA_Notify_VF</template>
    </alerts>
    <alerts>
        <fullName>ASI_CN_NPL_Item_Master_Alert_to_LOG</fullName>
        <description>ASI CN NPL Item Master Alert to LOG</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_NPL_Item_Master_Alert_to_LOG</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CN_NPL_Email_Template/ASI_CN_NPL_Item_Master_LOG_Notify_VF</template>
    </alerts>
    <alerts>
        <fullName>ASI_CN_NPL_Item_Master_Alert_to_OPS_TEC</fullName>
        <description>ASI CN NPL Item Master Alert to OPS TEC</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_NPL_Item_Master_Alert_to_OPS_TEC</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CN_NPL_Email_Template/ASI_CN_NPL_Item_Master_LOG_Notify_VF</template>
    </alerts>
    <alerts>
        <fullName>ASI_CN_NPL_Item_Master_Alert_to_Sales_Planning</fullName>
        <description>ASI CN NPL Item Master Alert to Sales Planning</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_NPL_Item_Master_AlerttoSales_Plan</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CN_NPL_Email_Template/ASI_CN_NPL_Item_Master_SP_Notify_VF</template>
    </alerts>
    <alerts>
        <fullName>ASI_CN_NPL_Item_Master_Complete_Alert_Existing</fullName>
        <description>ASI CN NPL Item Master Complete Alert - Existing</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_NPL_Item_Master_Complete_Existing</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CN_NPL_Email_Template/ASI_CN_NPL_Item_Master_Complete_VF</template>
    </alerts>
    <alerts>
        <fullName>ASI_CN_NPL_Item_Master_Complete_Alert_Existing_ItemGroup</fullName>
        <description>ASI CN NPL Item Master Complete Alert - Existing ItemGroup</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_NPL_BOT</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>ASI_CN_NPL_OPS_All</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CN_NPL_Email_Template/ASI_CN_NPL_Item_Master_Complete_VF</template>
    </alerts>
    <alerts>
        <fullName>ASI_CN_NPL_Item_Master_Complete_Alert_New_Brand</fullName>
        <description>ASI CN NPL Item Master Complete Alert - New Brand</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_NPL_Item_Master_Complete_NewBrand</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CN_NPL_Email_Template/ASI_CN_NPL_Item_Master_Complete_VF</template>
    </alerts>
    <alerts>
        <fullName>ASI_CN_NPL_Item_Master_Complete_Alert_New_Item</fullName>
        <description>ASI CN NPL Item Master Complete Alert - New Item</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_NPL_Item_Master_Complete_New_Item</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CN_NPL_Email_Template/ASI_CN_NPL_Item_Master_Complete_VF</template>
    </alerts>
    <alerts>
        <fullName>ASI_CN_NPL_Item_Master_Complete_Alert_New_ItemGroup</fullName>
        <description>ASI CN NPL Item Master Complete Alert - New ItemGroup</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_NPL_BOT</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>ASI_CN_NPL_IT_All</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>ASI_CN_NPL_Item_Master_Alert_to_Account</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>ASI_CN_NPL_Item_Master_Alert_to_BA</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>ASI_CN_NPL_Item_Master_AlerttoSales_Plan</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>ASI_CN_NPL_OPS_All</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CN_NPL_Email_Template/ASI_CN_NPL_Item_Master_Complete_VF</template>
    </alerts>
    <alerts>
        <fullName>ASI_CN_NPL_Item_Master_Complete_Alert_New_Item_New_Brand</fullName>
        <description>ASI CN NPL Item Master Complete Alert - New Item New Brand</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_NPL_Item_Master_Complete_New_I_B</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CN_NPL_Email_Template/ASI_CN_NPL_Item_Master_Complete_VF</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CN_NPL_Item_Master_Uncheck_Ignore</fullName>
        <field>ASI_CN_NPL_Ignore_Checking__c</field>
        <literalValue>0</literalValue>
        <name>ASI CN NPL Item Master Uncheck Ignore</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI CN NPL Item Master Complete Existing ItemGroup</fullName>
        <actions>
            <name>ASI_CN_NPL_Item_Master_Complete_Alert_Existing_ItemGroup</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CN_NPL_Item_Master__c.ASI_CN_NPL_Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CN_NPL_Item_Master__c.ASI_CN_NPL_New_Item_Group__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI CN NPL Item Master Complete New ItemGroup</fullName>
        <actions>
            <name>ASI_CN_NPL_Item_Master_Complete_Alert_New_ItemGroup</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CN_NPL_Item_Master__c.ASI_CN_NPL_Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CN_NPL_Item_Master__c.ASI_CN_NPL_New_Item_Group__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI CN NPL Item Master Notify BA</fullName>
        <actions>
            <name>ASI_CN_NPL_Item_Master_Alert_to_BA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CN_NPL_Item_Master__c.ASI_CN_NPL_Status__c</field>
            <operation>equals</operation>
            <value>Waiting For BA Input Category Code</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI CN NPL Item Master Notify DEMAND</fullName>
        <actions>
            <name>ASI_CN_NPL_Item_Master_Alert_to_LOG</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CN_NPL_Item_Master__c.ASI_CN_NPL_Status__c</field>
            <operation>equals</operation>
            <value>Waiting For Logistics Final Confirmation</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI CN NPL Item Master Notify LOG</fullName>
        <actions>
            <name>ASI_CN_NPL_Item_Master_Alert_to_LOG</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CN_NPL_Item_Master__c.ASI_CN_NPL_Status__c</field>
            <operation>equals</operation>
            <value>Waiting For Logistics Input Item Code,Waiting For Logistics Finalize Chinese Name</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI CN NPL Item Master Notify OPS TEC</fullName>
        <actions>
            <name>ASI_CN_NPL_Item_Master_Alert_to_OPS_TEC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CN_NPL_Item_Master__c.ASI_CN_NPL_Status__c</field>
            <operation>equals</operation>
            <value>Waiting for Logistics Input Cap Group</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI CN NPL Item Master Notify Sales Planning</fullName>
        <actions>
            <name>ASI_CN_NPL_Item_Master_Alert_to_Sales_Planning</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CN_NPL_Item_Master__c.ASI_CN_NPL_Status__c</field>
            <operation>equals</operation>
            <value>Waiting For Logistics Final Confirmation</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CN_NPL_Item_Master__c.ASI_CN_NPL_New_Item_Group__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI CN NPL Item Master Uncheck Ignore Checking</fullName>
        <actions>
            <name>ASI_CN_NPL_Item_Master_Uncheck_Ignore</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CN_NPL_Item_Master__c.ASI_CN_NPL_Ignore_Checking__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
