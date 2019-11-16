#include <sourcemod>

//Defines
#define VERSION "1.01"

//Demo save time
ConVar cvar_demo_save_time = null;

public Plugin myinfo =
{
  name = "CSGO Demo Delete",
  author = "Invex | Byte",
  description = "Deletes old demos from demo folder.",
  version = VERSION,
  url = "https://invex.gg"
};

// Plugin Start
public void OnPluginStart()
{
  RegAdminCmd("sm_deletedemos", Command_Delete_Demos, ADMFLAG_ROOT, "Delete old demos from demo folder");
  
  cvar_demo_save_time = CreateConVar("sm_demosavetime", "604800", "How many seconds to save demo for. (def. 604800)");
  
  //Create config file
  AutoExecConfig(true, "csgo_demo_delete");
}

//Delete Demos
public Action Command_Delete_Demos(int client, int args)
{
  //Go through all demo files
  Handle dirHandle = OpenDirectory("demo");
  char buffer[256];
  FileType type = FileType_File;
  
  //Loop through files
  while (ReadDirEntry(dirHandle, buffer, sizeof(buffer), type))
  {
    //File name too short
    if (strlen(buffer) < 4)
      continue;
    
    char extensionType[6];
    Format(extensionType, sizeof(extensionType), "%s", buffer[strlen(buffer)-4]);
  
    //Only process demo files
    if (!StrEqual(extensionType, ".dem", false))
      continue;
    
    //Get the epoch timestamp for the file creation date
    char demoFilePath[256];
    Format(demoFilePath, sizeof(demoFilePath), "demo/%s", buffer);
    int creationTimestamp = GetFileTime(demoFilePath, FileTime_Created);
    
    //Check for error
    if (creationTimestamp == -1)
      continue;
    
    //Otherwise, check for old demos
    if (GetTime() - creationTimestamp > GetConVarInt(cvar_demo_save_time)) {
      //This is an old file, delete it
      if (!DeleteFile(demoFilePath)) {
        LogError("Failed to delete demo file at %s.", demoFilePath);
      }
    }
  }
}