# type ;  ID     ;  name             ; ID2  ; data   ;  FR         ;  EN
# STR# ;  10006  ;  Textes Othellier ; 1    ;        ;  NOIRS:     ;  BLACK:
# STR# ;  10006  ;  Textes Othellier ; 2    ;        ;  BLANCS:    ;  WHITE:

import json

# renvoie les n premiers caractères d'une chaine et le reste
def cut(s, n):
    return s[0:n], s[n:]

######################################################################
# Gestion des ALRT
def outputALRT2str(ID, alert):
    outputString = 'ALRT;'
    outputString += ID +';'    # ID
    outputString += ';' # name
    outputString +=  '; ' # ID2
    outputString += alert['data'] + ';' # data
    outputString +=  alert['name'] + ';' # FR
    outputString +=  ';\n' # GB
    return outputString

######################################################################
# Gestion des menus

def extractMENUdata(dataString):
    d = dict()
    menuID, dataString = cut(dataString, 4)
    d['menuID'] = int(menuID, 16)
    largeur, dataString = cut(dataString, 4)
    d['largeur'] = int(largeur, 16)
    hauteur, dataString = cut(dataString, 4)
    d['hauteur'] = int(hauteur, 16)
    procID, dataString = cut(dataString, 4)
    d['procID'] = int(procID, 16)
    filler, dataString = cut(dataString, 4)
    d['filler'] = filler
    flags, dataString = cut(dataString, 8)
    d['flags'] = flags
    n, dataString = cut(dataString, 2)
    titre, dataString = cut(dataString, int(n,16)*2)
    d['name'] = ''.join([bytes.fromhex(titre[i:i+2]).decode('mac-roman') for i in range(0, len(titre), 2)]).replace('\r','\\n')
    d['chaines']= []
    itemID = 1
    while (dataString != ''):
        n, dataString = cut(dataString, 2)
        n = int(n,16)*2
        if (n == 0):
            break
        chaine, dataString = cut(dataString, n)
        menu = {}
        menu['itemID'] = itemID
        itemID += 1
        menu['string']=(''.join([bytes.fromhex(chaine[i:i+2]).decode('mac-roman') for i in range(0, len(chaine), 2)])).replace('\r','\\n')
        icon, dataString = cut(dataString, 2)
        keyEquiv, dataString = cut(dataString, 2)
        if (keyEquiv != '00'):
            keyEquiv = bytes.fromhex(keyEquiv).decode('mac-roman')
            menu['keyEquiv'] = keyEquiv
        mark, dataString = cut(dataString, 2)
        style, dataString = cut(dataString, 2)
        d['chaines'].append(menu)

    return d

# ligne pour un MENU
def outputMENU2str(ID, menuData):
    d = extractMENUdata(menuData)
    outputString = 'MENU;'
    outputString += str(ID) +';'    # ID
    outputString += ';' # name
    outputString += '0;' # ID2
    outputString += 'flags=' + d['flags'] + ';' # data
    outputString += d['name'] + ';' # FR
    outputString +=  ';\n' # GB
    for sd in d['chaines']:
        outputString += 'MENU;'
        outputString += str(ID) +';'    # ID
        outputString += d['name'] +';' # name
        outputString += str(sd['itemID']) +';' # ID2
        if 'keyEquiv' in sd:
            outputString += 'keyEquiv='+ sd['keyEquiv']
        outputString += ';' # data
        outputString += sd['string'] +';' # FR
        outputString +=  ';\n' # GB
    return outputString


######################################################################
# Gestion des DITL
def extractDITLdata(dataString):
    L = []
    n, dataString = cut(dataString, 4)
    for i in range(1,int(n, 16)+1):
        d = {}
        d['itemID'] = i
        padding, dataString = cut(dataString, 8)
        top, dataString = cut(dataString, 4)
        d['top'] = int(top, 16)
        left, dataString = cut(dataString, 4)
        d['left'] = int(left, 16)
        bottom, dataString = cut(dataString, 4)
        d['bottom'] = int(bottom, 16)
        right, dataString = cut(dataString, 4)
        d['right'] = int(right,16)
        flags, dataString = cut(dataString, 2)
        d['flags'] = "0x"+flags
        lgrChaineStr, dataString = cut(dataString, 2)
        lgrChaine = int(lgrChaineStr,16)*2
        chaine, dataString = cut(dataString, lgrChaine)
        d['chaine'] = ''.join([bytes.fromhex(chaine[i:i+2]).decode('mac-roman') for i in range(0, lgrChaine, 2)]).replace('\r','\\n')
        if ((lgrChaine/2) %2 == 1):
            padding, dataString = cut(dataString, 2)
        L.append(d)
    return L

def outputDITL2str(ID, ditl):
    L = extractDITLdata(ditl['data'])
    outputString = ""
    for item in L:
        outputString += 'DITL;'
        outputString += str(ID) +';'    # ID
        if 'name' in ditl:
            outputString += ditl['name']
        outputString += ';' # name
        outputString += str(item['itemID']) +';'    # ID2
        outputString += "posAndFlags= "
        outputString += str(item['top']) + " "
        outputString += str(item['left']) + " "
        outputString += str(item['bottom']) + " "
        outputString += str(item['right']) + "  "
        outputString += item['flags'] + ";" # data
        outputString += item['chaine'] +';' # FR
        outputString +=  ';\n' # GB
    return outputString

######################################################################
# Gestion des STR#
def outputSTR2str(ID, string):
    outputString = 'STR#;'
    outputString += str(ID) +';'    # ID
    outputString += ';' # name
    outputString += '0;' # ID2
    outputString += ';' # data
    outputString += string['name'] + ';' # FR
    outputString +=  ';\n' # GB

    for i in range(len(string['obj'])):
        outputString += 'STR#;'
        outputString += str(ID) +';'    # ID
        outputString += string['name'] +';' # name
        outputString += str(i+1) + ';' # ID2
        outputString += ';' # data
        outputString += string['obj'][i].replace('\r','\\n') + ';' # FR
        outputString +=  ';\n' # GB
    return outputString

######################################################################
# Gestion des DLOG
def extractDLOGdata(dlogData):
    dummy, dlogData = cut(dlogData, 40)
    lgrChaineStr, dlogData = cut(dlogData, 2)
    lgrChaine = int(lgrChaineStr,16)*2
    chaine, dlogData = cut(dlogData, lgrChaine)
    return ''.join([bytes.fromhex(chaine[i:i+2]).decode('mac-roman') for i in range(0, lgrChaine, 2)]).replace('\r','\\n')

def outputDLOG2str(ID, dlog):
    outputString = 'DLOG;'
    outputString += ID +';'    # ID
    outputString += dlog['name'] + ';' # name
    outputString +=  '; ' # ID2
    outputString +=  ';' # data
    outputString += extractDLOGdata(dlog['data']) + ';' # FR
    outputString +=  ';\n' # GB
    return outputString


######################################################################

# read JSON file and parse contents
with open('Cassio.json', 'r') as file:
    python_obj = json.load(file)
with open('extract_Cassio.csv', 'w', encoding='utf-8-sig') as fileOutput:
    fileOutput.write("type; ID; name; ID2; data; FR; EN;\n")
    La = python_obj['ALRT']
    for ID, item in La.items():
        fileOutput.write(outputALRT2str(ID, item))
    Ld = python_obj['DITL']
    for ID, item in Ld.items():
        fileOutput.write(outputDITL2str(ID, item))
    Ldl = python_obj['DLOG']
    for ID, item in Ldl.items():
        fileOutput.write(outputDLOG2str(ID, item))
    Lm = python_obj['MENU']
    for ID, item in Lm.items():
        fileOutput.write(outputMENU2str(ID, item['data']))
    Ls = python_obj['STR#']
    for ID, item in Ls.items():
        fileOutput.write(outputSTR2str(ID, item))


