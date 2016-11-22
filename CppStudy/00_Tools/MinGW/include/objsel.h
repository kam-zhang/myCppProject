/*
 * objsel.h - Active Directory
 *
 * THIS SOFTWARE IS NOT COPYRIGHTED
 *
 * This source code is offered for use in the public domain.  You may use,
 * modify or distribute it freely.
 *
 * This code is distributed in the hope that it will be useful but
 * WITHOUT ANY WARRANTY.  ALL WARRANTIES, EXPRESS OR IMPLIED ARE HEREBY
 * DISCLAIMED.  This includes but is not limited to warranties of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 */
#ifndef _OBJSEL_H
#define _OBJSEL_H
#if __GNUC__ >= 3
#pragma GCC system_header
#endif

#ifdef __cplusplus
extern "C" {
#endif

/*--- Active Directory Reference - Active Directory Structures - Object Picker Dialog Box Structures */
#if (_WIN32_WINNT >= 0x0500)
typedef struct _DS_SELECTION {
	PWSTR pwzName;
	PWSTR pwzADsPath;
	PWSTR pwzClass;
	PWSTR pwzUPN;
	VARIANT *pvarFetchedAttributes;
	ULONG flScopeType;
} DS_SELECTION,*PDS_SELECTION;
typedef struct _DS_SELECTION_LIST {
	ULONG cItems;
	ULONG cFetchedAttributes;
	DS_SELECTION aDsSelection[ANYSIZE_ARRAY];
} DS_SELECTION_LIST,*PDS_SELECTION_LIST;

typedef struct _DSOP_UPLEVEL_FILTER_FLAGS {
	ULONG flBothModes;
	ULONG flMixedModeOnly;
	ULONG flNativeModeOnly;
} DSOP_UPLEVEL_FILTER_FLAGS;
#define DSOP_FILTER_INCLUDE_ADVANCED_VIEW 0x00000001
#define DSOP_FILTER_USERS 0x00000002
#define DSOP_FILTER_BUILTIN_GROUPS 0x00000004
#define DSOP_FILTER_WELL_KNOWN_PRINCIPALS 0x00000008
#define DSOP_FILTER_UNIVERSAL_GROUPS_DL 0x00000010
#define DSOP_FILTER_UNIVERSAL_GROUPS_SE 0x00000020
#define DSOP_FILTER_GLOBAL_GROUPS_DL 0x00000040
#define DSOP_FILTER_GLOBAL_GROUPS_SE 0x00000080
#define DSOP_FILTER_DOMAIN_LOCAL_GROUPS_DL 0x00000100
#define DSOP_FILTER_DOMAIN_LOCAL_GROUPS_SE 0x00000200
#define DSOP_FILTER_CONTACTS 0x00000400
#define DSOP_FILTER_COMPUTERS 0x00000800
typedef struct _DSOP_FILTER_FLAGS {
	DSOP_UPLEVEL_FILTER_FLAGS Uplevel;
	ULONG flDownlevel;
} DSOP_FILTER_FLAGS;
#define DSOP_DOWNLEVEL_FILTER_USERS 0x80000001
#define DSOP_DOWNLEVEL_FILTER_LOCAL_GROUPS 0x80000002
#define DSOP_DOWNLEVEL_FILTER_GLOBAL_GROUPS 0x80000004
#define DSOP_DOWNLEVEL_FILTER_COMPUTERS 0x80000008
#define DSOP_DOWNLEVEL_FILTER_WORLD 0x80000010
#define DSOP_DOWNLEVEL_FILTER_AUTHENTICATED_USER 0x80000020
#define DSOP_DOWNLEVEL_FILTER_ANONYMOUS 0x80000040
#define DSOP_DOWNLEVEL_FILTER_BATCH 0x80000080
#define DSOP_DOWNLEVEL_FILTER_CREATOR_OWNER 0x80000100
#define DSOP_DOWNLEVEL_FILTER_CREATOR_GROUP 0x80000200
#define DSOP_DOWNLEVEL_FILTER_DIALUP 0x80000400
#define DSOP_DOWNLEVEL_FILTER_INTERACTIVE 0x80000800
#define DSOP_DOWNLEVEL_FILTER_NETWORK 0x80001000
#define DSOP_DOWNLEVEL_FILTER_SERVICE 0x80002000
#define DSOP_DOWNLEVEL_FILTER_SYSTEM 0x80004000
#define DSOP_DOWNLEVEL_FILTER_EXCLUDE_BUILTIN_GROUPS 0x80008000
#define DSOP_DOWNLEVEL_FILTER_TERMINAL_SERVER 0x80010000
#define DSOP_DOWNLEVEL_FILTER_ALL_WELLKNOWN_SIDS 0x80020000
#define DSOP_DOWNLEVEL_FILTER_LOCAL_SERVICE 0x80040000
#define DSOP_DOWNLEVEL_FILTER_NETWORK_SERVICE 0x80080000
#define DSOP_DOWNLEVEL_FILTER_REMOTE_LOGON 0x80100000
typedef struct _DSOP_SCOPE_INIT_INFO {
	ULONG cbSize;
	ULONG flType;
	ULONG flScope;
	DSOP_FILTER_FLAGS FilterFlags;
	PCWSTR pwzDcName;
	PCWSTR pwzADsPath;
	HRESULT hr;
} DSOP_SCOPE_INIT_INFO,*PDSOP_SCOPE_INIT_INFO,*PCDSOP_SCOPE_INIT_INFO;
#define DSOP_SCOPE_TYPE_TARGET_COMPUTER 0x00000001
#define DSOP_SCOPE_TYPE_UPLEVEL_JOINED_DOMAIN 0x00000002
#define DSOP_SCOPE_TYPE_DOWNLEVEL_JOINED_DOMAIN 0x00000004
#define DSOP_SCOPE_TYPE_ENTERPRISE_DOMAIN 0x00000008
#define DSOP_SCOPE_TYPE_GLOBAL_CATALOG 0x00000010
#define DSOP_SCOPE_TYPE_EXTERNAL_UPLEVEL_DOMAIN 0x00000020
#define DSOP_SCOPE_TYPE_EXTERNAL_DOWNLEVEL_DOMAIN 0x00000040
#define DSOP_SCOPE_TYPE_WORKGROUP 0x00000080
#define DSOP_SCOPE_TYPE_USER_ENTERED_UPLEVEL_SCOPE 0x00000100
#define DSOP_SCOPE_TYPE_USER_ENTERED_DOWNLEVEL_SCOPE 0x00000200
typedef struct _DSOP_INIT_INFO {
	ULONG cbSize;
	PCWSTR pwzTargetComputer;
	ULONG cDsScopeInfos;
	PDSOP_SCOPE_INIT_INFO aDsScopeInfos;
	ULONG flOptions;
	ULONG cAttributesToFetch;
	PCWSTR* apwzAttributeNames;
} DSOP_INIT_INFO,*PDSOP_INIT_INFO;
#define DSOP_FLAG_MULTISELECT 0x00000001
#define DSOP_FLAG_SKIP_TARGET_COMPUTER_DC_CHECK 0x00000002
#endif /* (_WIN32_WINNT >= 0x0500) */

#ifdef __cplusplus
}
#endif
#endif
