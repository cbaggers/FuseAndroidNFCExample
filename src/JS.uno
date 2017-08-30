using Uno;
using Uno.UX;
using Uno.Threading;
using Uno.Text;
using Uno.Platform;
using Uno.Compiler.ExportTargetInterop;
using Uno.Collections;
using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;

namespace Fuse.NFC
{
    /**
    */
    [UXGlobalModule]
    public sealed class NFCModule : NativeEventEmitterModule
    {
        static readonly NFCModule _instance;

        public NFCModule(): base(true, "tagDiscovered", "techDiscovered", "ndefDiscovered")
        {
            if(_instance != null) return;
            Uno.UX.Resource.SetGlobalKey(_instance = this, "NFC");

            var tagDiscovered = new NativeEvent("tagDiscovered");
            On("tagDiscovered", tagDiscovered);
            AddMember(tagDiscovered);

            var techDiscovered = new NativeEvent("techDiscovered");
            On("techDiscovered", techDiscovered);
            AddMember(techDiscovered);

            var ndefDiscovered = new NativeEvent("ndefDiscovered");
            On("ndefDiscovered", ndefDiscovered);
            AddMember(ndefDiscovered);

            Scanner.Init();
        }

        public static void OnTagDiscovered(string message)
        {
            _instance.Emit("tagDiscovered", message);
        }
    }

    [ForeignInclude(Language.Java, "android.nfc.NfcAdapter", "android.content.Intent")]
    extern(android)
    class Scanner
    {
        static Java.Object _handle = null;
        static Java.Object _listener = null;

        [Foreign(Language.Java)]
        public static void Init()
        @{
            NfcAdapter adapter = NfcAdapter.getDefaultAdapter(com.fuse.Activity.getRootActivity());
            if (adapter != null)
            {
                com.fuse.Activity.IntentListener listener = new com.fuse.Activity.IntentListener()
                {
                    public void onIntent (Intent newIntent)
                    {
                        @{NFCModule.OnTagDiscovered(string):Call("YAY!")};
                    }
                };
                com.fuse.Activity.subscribeToIntents(listener, NfcAdapter.ACTION_NDEF_DISCOVERED);
                com.fuse.Activity.subscribeToIntents(listener, NfcAdapter.ACTION_TECH_DISCOVERED);
                com.fuse.Activity.subscribeToIntents(listener, NfcAdapter.ACTION_TAG_DISCOVERED);
                @{Scanner._listener:Set(listener)};
                @{Scanner._handle:Set(adapter)};
            }
            else
            {
                debug_log("NFC not supported");
            }
        @}
    }

    extern(!android)
    class Scanner
    {
        public void Init() {}
    }
}
