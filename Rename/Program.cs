using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;

namespace Rename
{
    class Program
    {
        static List<String> forbiddenCharacters = new List<String>(){ "<", ">", ":", "\"", "/", "\\", "|", "?", "*" };

        static String cleanFileName(String fileName)
        {
            String cleanFileName = fileName;
            foreach (var character in forbiddenCharacters)
            {
                cleanFileName = cleanFileName.Replace(character, "");
            }
            return cleanFileName;
        }

        static void Main(string[] args)
        {
            String basePath = "C:\\Users\\Mekni-Wassime\\Documents\\Misc\\RadioLosSantos\\audio\\";
            StreamReader r = new StreamReader(basePath+"names.json");
            string jsonString = r.ReadToEnd();
            List<FolderData> jsonList = JsonConvert.DeserializeObject<List<FolderData>>(jsonString);

            int totalNumberOfFiles = 0;
            int numberOfFilesTreated = 0;
            foreach (var item in jsonList)
                totalNumberOfFiles += item.titles.Count;
            
            
            String newFolderPath = basePath + "Radio Los Santos";
            Directory.CreateDirectory(newFolderPath);
            foreach (var item in jsonList)
            {
                String newSubFolderPath = newFolderPath+ "\\" + item.station;
                Directory.CreateDirectory(newSubFolderPath);
                for (int i = 1; i < 1000; i++)
                {
                    String oldFilePath = basePath + item.stream + "\\" + "Track_"+ i.ToString("D3")+".ogg";
                    if (!File.Exists(oldFilePath))
                        break;
                    
                    String newFilePath = newSubFolderPath + "\\" + cleanFileName(item.titles[i - 1])+".ogg";
                    File.Copy(oldFilePath, newFilePath);
                    numberOfFilesTreated++;
                    //Console.Clear();
                    Console.WriteLine(numberOfFilesTreated + "/" + totalNumberOfFiles);
                }
            }
        }
    }

    class FolderData
    {
        public String stream;
        public String station;
        public List<String> titles;
    }
}
