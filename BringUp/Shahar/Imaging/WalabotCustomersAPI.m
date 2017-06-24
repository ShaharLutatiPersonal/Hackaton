clear
try
    lemire_engine(1,1);
catch
    cd('C:\Users\User\Google Drive\HackNProtect\MinMaxFilterFolder');
    minmaxfilter_install();
end
cd ('C:\Users\User\Google Drive\HackNProtect');
asm=NET.addAssembly('C:\Program Files\Walabot\WalabotSDK\bin\x64\WalabotAPI.NET.dll');
API = WalabotAPI_NET.WalabotAPI;
API.SetSettingsFolder('C:/ProgramData/Walabot/WalabotSDK');
API.ConnectAny();
profile = WalabotAPI_NET.APP_PROFILE.PROF_SENSOR;
Filter_MTI = WalabotAPI_NET.FILTER_TYPE.FILTER_TYPE_MTI;
Filter_Dev = WalabotAPI_NET.FILTER_TYPE.FILTER_TYPE_DERIVATIVE;
API.SetProfile(profile);
API.SetDynamicImageFilter(Filter_Dev);
API.SetArenaR(10, 1000, 10);
API.SetArenaTheta(1, 50, 10);
API.SetArenaPhi(1, 50, 10);
API.Start;
API.Trigger;
A = API.GetRawImage();
Mat = double(int32(A));
~isempty(find(Mat(:)~=0))
T = API.GetSensorTargets;
Mat(Mat <= max(Mat(:))*10^(-20/20))=nan;
 h = slice(Mat,[],[],1:size(Mat,3));
 set(h,'EdgeColor','none','FaceColor','interp')
alpha(0.1)
API.Disconnect