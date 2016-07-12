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
 * mimic WorkflowStatus.js, specifically the the status.
 *
 * @author mprins
 */
public enum WorkflowStatus {

    // explicitly using lowercase, to mimic the javascript
    bewerkt("Bewerkt"),
    definitief("Definitief"),
    archief("Archief"),
    afgevoerd("Afgevoerd");

    private final String label;

    WorkflowStatus(String label) {
        this.label = label;
    }

    public String label() {
        return this.label;
    }

}
