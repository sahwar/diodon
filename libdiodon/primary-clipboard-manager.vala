/*
 * Diodon - GTK+ clipboard manager.
 * Copyright (C) 2011 Diodon Team <diodon-team@lists.launchpad.net>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
 * License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Diodon
{
    /**
     * Specific clipboard manager for primary selection extending
     * basic functionality with primary selection specific use cases.
     * Note that primary selection clipboard manager only supports text.
     * 
     * @author Oliver Sauder <os@esite.ch>
     */
    class PrimaryClipboardManager : ClipboardManager
    {
        /**
         * Type is alwawys ClipboardType.PRIMARY for this specific primary
         * selection manager.
         */
        public PrimaryClipboardManager()
        {
            base(ClipboardType.PRIMARY);
        }
        
        /**
         * Owner does not always get changed when selection has been changed
         * therefore we need a timer for the primary selection.
         */
        public override void start()
        {
            Timeout.add(500, request_text_callback);
        }
        
        /**
         * Primary selection only supports text therefore ignoring
         * all others.
         *
         * @param item clipboard item to be selected
         */
        public override void select_item(IClipboardItem item)
        {
            if(item is TextClipboardItem) {
                base.select_item(item);
            }
        }
    
        /**
         * Check if the mouse button or shift button is pressed
         * before primary selection gets accepted. As otherwise the history
         * gets flooded with several clipboard items.
         *
         * @return true if button are in an acceptable state; otherwise false.
         */
        private bool check_button_state()
        {
            Gdk.Window rootwin = Gdk.get_default_root_window();
            Gdk.Display display = rootwin.get_display();
            Gdk.ModifierType modifier = 0;
            
            Gdk.Device device = display.get_device_manager().get_client_pointer();
            device.get_state(rootwin, (double[])null, out modifier);
            
            // only accepted when left mouse button and shift button
            // are not pressed
            if((modifier & Gdk.ModifierType.BUTTON1_MASK) == 0) {
                if((modifier & Gdk.ModifierType.SHIFT_MASK) == 0) {
                    return true;
                }
            }
            
            return false;
        }
        
        /**
         * Helper method for requesting primary text within a timer
         * 
         * @return always true, no stopping of timer
         */
        private bool request_text_callback()
        {
            // checking for text
            string? text = request_text();
            if(text != null && text != "") {
            
                // check if text can be accepted
                if(check_button_state()) {
                    on_text_received(type, text);
                }
            }
            // checking if clipboard might be empty
            else {
                check_clipboard_emptiness();
            }
            
            return true;
        }
    }
}

