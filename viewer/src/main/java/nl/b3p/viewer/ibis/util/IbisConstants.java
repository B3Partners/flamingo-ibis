/*
 * Copyright (C) 2015 B3Partners B.V.
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
package nl.b3p.viewer.ibis.util;

/**
 * Utility interface with constants for IBIS.
 *
 * @author Mark Prins <mark@b3partners.nl>
 */
public interface IbisConstants {

    public static final String KAVEL_LAYER_NAME = "bedrijvenkavels";
    public static final String TERREIN_LAYER_NAME = "bedrijventerrein";
    /**
     * Name of the foreign TERREIN ID field in the datamodel (exists only in
     * {@link IbisConstants#KAVEL_LAYER_NAME). {@value}.
     */
    public static final String KAVEL_TERREIN_ID_FIELDNAME = "terreinid";
    /**
     * name of the ID field in the datamodel. {@value}.
     */
    public static final String ID_FIELDNAME = "id";
    /**
     * name of the workflow field in the datamodel. {@value}.
     */
    public static final String WORKFLOW_FIELDNAME = "workflow_status";
    /**
     * name of the mutatiedatum field in the datamodel. {@value}.
     */
    public static final String MUTATIEDATUM_FIELDNAME = "datummutatie";
}
