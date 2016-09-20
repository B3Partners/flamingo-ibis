/*
 * Copyright (C) 2016 B3Partners B.V.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package nl.b3p.viewer.stripes;

import net.sourceforge.stripes.action.ActionBean;
import net.sourceforge.stripes.action.StrictBinding;
import net.sourceforge.stripes.action.UrlBinding;
import nl.b3p.viewer.ibis.util.IbisConstants;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 *
 * @author mprins
 */
@UrlBinding("/action/feature/ibisdrawing")
@StrictBinding
public class IbisDrawingActionBean extends BookmarkActionBean implements ActionBean, IbisConstants {

    private static final Log log = LogFactory.getLog(IbisDrawingActionBean.class);

   

    //<editor-fold defaultstate="collapsed" desc="getters en setters">
  

    //</editor-fold>
}
