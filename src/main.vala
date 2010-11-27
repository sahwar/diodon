/*
 * Diodon - GTK+ clipboard manager.
 * Copyright (C) 2010 Diodon Team <diodon-team@lists.launchpad.net>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Diodon
{
    /**
     * Main class is responsible for creating all needed views, controllers
     * and models and starting the GUI application.
     *
     * @author Oliver Sauder <os@esite.ch>
     */
    public class Main
    {
        public static int main(string[] args)
        {
            string diodon_dir =  Environment.get_home_dir()
                + "/.local/share/diodon";
        
            // setup gettext
            Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
            Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "UTF-8");

            Gtk.init(ref args);
            
            // setup controller    
            IndicatorView indicator = new IndicatorView();
            IClipboardStorage storage = new XmlClipboardStorage(diodon_dir, "storage.xml");
            ClipboardModel model = new ClipboardModel(storage);
            
            Gee.ArrayList<ClipboardManager> clipboard_managers = new Gee.ArrayList<ClipboardManager>();
            Gtk.Clipboard clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD);
            ClipboardManager clipboard_manager = new ClipboardManager(clipboard, ClipboardType.CLIPBOARD);
            clipboard_managers.add(clipboard_manager);
            Gtk.Clipboard primary = Gtk.Clipboard.get(Gdk.SELECTION_PRIMARY);
            ClipboardManager primary_manager = new ClipboardManager(primary, ClipboardType.PRIMARY);
            clipboard_managers.add(primary_manager);
            
            Controller controller = new Controller(indicator, model, clipboard_managers);
            controller.start();
            
            Gtk.main();
            return 0;
        }
    }
}

