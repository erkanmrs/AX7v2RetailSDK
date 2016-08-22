SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (SELECT OBJECT_ID('ax.RETAILCUSTPREFERENCE')) IS NULL 
BEGIN
	CREATE TABLE [ax].[RETAILCUSTPREFERENCE](
		[DATAAREAID] [nvarchar](4) NOT NULL,
		[RECID] [bigint] NOT NULL,
		[EMAILOPTIN] [int] NOT NULL,
		[ACCOUNTNUM] [nvarchar](20) NOT NULL,
	 CONSTRAINT [I_103992RECID] PRIMARY KEY CLUSTERED 
	(
		[RECID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]

	ALTER TABLE [ax].[RETAILCUSTPREFERENCE]  WITH CHECK ADD CHECK  (([RECID]<>(0)))

	ALTER TABLE [ax].[RETAILCUSTPREFERENCE] ADD  DEFAULT ('dat') FOR [DATAAREAID]

	ALTER TABLE [ax].[RETAILCUSTPREFERENCE] ADD  DEFAULT ((0)) FOR [EMAILOPTIN]

	ALTER TABLE [ax].[RETAILCUSTPREFERENCE] ADD  DEFAULT ('') FOR [ACCOUNTNUM]

END
GO

-- grant Read/Insert/Update/Delete permission to DataSyncUserRole so CDX can function
GRANT SELECT ON OBJECT::[ax].[RETAILCUSTPREFERENCE] TO [DataSyncUsersRole]
GO
GRANT INSERT ON OBJECT::[ax].[RETAILCUSTPREFERENCE] TO [DataSyncUsersRole]
GO
GRANT UPDATE ON OBJECT::[ax].[RETAILCUSTPREFERENCE] TO [DataSyncUsersRole]
GO
GRANT DELETE ON OBJECT::[ax].[RETAILCUSTPREFERENCE] TO [DataSyncUsersRole]
GO
