/*PGR-GNU*****************************************************************

File: pgdata_fetchers.cpp

Copyright (c) 2024 pgRouting developers
Mail: pgrouting-dev@discourse.osgeo.org

Developer:
Copyright (c) 2024 Celia Virginia Vergara Castillo
Mail: vicky at erosion.dev

------

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

 ********************************************************************PGR-GNU*/

#include "cpp_common/pgdata_fetchers.hpp"

#include <structures/vroom/input/input.h>
#include <structures/vroom/job.h>
#include <structures/vroom/vehicle.h>

#include <string>
#include <climits>
#include <vector>

#include "cpp_common/info.hpp"
#include "cpp_common/check_get_data.hpp"

#include "cpp_common/vroom_break_t.hpp"
#include "cpp_common/vroom_job_t.hpp"
#include "cpp_common/vroom_matrix_t.hpp"
#include "cpp_common/vroom_shipment_t.hpp"
#include "cpp_common/vroom_time_window_t.hpp"
#include "cpp_common/vroom_vehicle_t.hpp"

namespace pgvroom {
namespace pgget {

namespace vroom {

Vroom_break_t
fetch_breaks(
        const HeapTuple tuple, const TupleDesc &tupdesc,
        const std::vector<Info> &info,
        bool) {
    Vroom_break_t vroom_break;
    vroom_break.id = get_value<Idx>(tuple, tupdesc, info[0], 0);
    vroom_break.vehicle_id = get_value<Idx>(tuple, tupdesc, info[1], 0);
    vroom_break.service = get_value<Duration>(tuple, tupdesc, info[2], 0);
    vroom_break.data = get_jsonb(tuple, tupdesc, info[3]);
    return vroom_break;
}

Vroom_matrix_t
fetch_matrix(
        const HeapTuple tuple, const TupleDesc &tupdesc,
        const std::vector<Info> &info,
        bool) {
    Vroom_matrix_t matrix;
    matrix.start_id = get_value<MatrixIndex>(tuple, tupdesc, info[0], -1);
    matrix.end_id = get_value<MatrixIndex>(tuple, tupdesc, info[1], -1);
    matrix.duration = get_value<Duration>(tuple, tupdesc, info[2], 0);
    matrix.cost = get_value<TravelCost>(tuple, tupdesc, info[3], matrix.duration);
    return matrix;
}

Vroom_time_window_t
fetch_timewindows(
        const HeapTuple tuple, const TupleDesc &tupdesc,
        const std::vector<Info> &info,
        bool is_shipment) {
    Vroom_time_window_t time_window;

    time_window.id = get_value<Idx>(tuple, tupdesc, info[0], 0);
    time_window.kind = is_shipment? get_char(tuple, tupdesc, info[3], ' ') : ' ';

    if (is_shipment) {
        if (time_window.kind != 'p' && time_window.kind != 'd') {
            throw std::string("Invalid kind '") + time_window.kind + "', Expecting 'p' or 'd'";
        }
    }

    Duration tw_open = get_value<Duration>(tuple, tupdesc, info[1], 0);
    Duration tw_close = get_value<Duration>(tuple, tupdesc, info[2], 0);

    if (tw_open > tw_close) {
        throw std::string("Invalid time window found: '") + info[2].name + "' < '" + info[1].name + "'";
    }

    time_window.tw = ::vroom::TimeWindow(tw_open, tw_close);

    return time_window;
}

Vroom_job_t
fetch_jobs(
        const HeapTuple tuple, const TupleDesc &tupdesc,
        const std::vector<Info> &info,
        bool) {
    Vroom_job_t job;

    job.id = get_value<Idx>(tuple, tupdesc, info[0], 0);
    job.location_id = get_value<MatrixIndex>(tuple, tupdesc, info[1], 0);

    job.setup = get_value<Duration>(tuple, tupdesc, info[2], 0);
    job.service = get_value<Duration>(tuple, tupdesc, info[3], 0);

    auto pickup = get_array<Amount>(tuple, tupdesc, info[5]);
    auto delivery = get_array<Amount>(tuple, tupdesc, info[4]);

    for (const auto &e : pickup) {
        job.pickup.push_back(e);
    }

    for (const auto &e : delivery) {
        job.delivery.push_back(e);
    }

    job.skills = get_uint_unordered_set(tuple, tupdesc, info[6]);
    job.priority = get_value<Priority>(tuple, tupdesc, info[7], 0);
    job.data = get_jsonb(tuple, tupdesc, info[8]);

    if (job.priority > 100) {
        throw std::string("Invalid value in column '") + info[7].name + "'. Maximum value allowed 100";
    }
    return job;
}

Vroom_shipment_t
fetch_shipments(
        const HeapTuple tuple, const TupleDesc &tupdesc,
        const std::vector<Info> &info,
        bool) {
    Vroom_shipment_t shipment;

    shipment.id = get_value<Idx>(tuple, tupdesc, info[0], 0);

    shipment.p_location_id = get_value<MatrixIndex>(tuple, tupdesc, info[1], 0);
    shipment.d_location_id = get_value<MatrixIndex>(tuple, tupdesc, info[4], 0);

    shipment.p_setup = get_value<Duration>(tuple, tupdesc, info[2], 0);
    shipment.p_service = get_value<Duration>(tuple, tupdesc, info[3], 0);
    shipment.d_setup = get_value<Duration>(tuple, tupdesc, info[5], 0);
    shipment.d_service = get_value<Duration>(tuple, tupdesc, info[6], 0);

    auto amount = get_array<Amount>(tuple, tupdesc, info[7]);

    for (const auto &a : amount) {
        shipment.amount.push_back(a);
    }

    shipment.skills = get_uint_unordered_set(tuple, tupdesc, info[8]);

    shipment.priority = get_value<Priority>(tuple, tupdesc, info[9], 0);

    shipment.p_data = get_jsonb(tuple, tupdesc, info[10]);
    shipment.d_data = get_jsonb(tuple, tupdesc, info[11]);

    if (shipment.priority > 100) {
        throw std::string("Invalid value in column '") + info[9].name + "'. Maximum value allowed 100";
    }
    return shipment;
}

Vroom_vehicle_t
fetch_vehicles(
        const HeapTuple tuple, const TupleDesc &tupdesc,
        const std::vector<Info> &info,
        bool) {
    Vroom_vehicle_t vehicle;
    vehicle.id = get_value<Idx>(tuple, tupdesc, info[0], 0);
    vehicle.start_id = get_value<MatrixIndex>(tuple, tupdesc, info[1], -1);
    vehicle.end_id = get_value<MatrixIndex>(tuple, tupdesc, info[2], -1);

    auto capacity = get_array<Amount>(tuple, tupdesc, info[3]);

    for (const auto &c : capacity) {
        vehicle.capacity.push_back(c);
    }

    vehicle.skills = get_uint_unordered_set(tuple, tupdesc, info[4]);

    Duration tw_open = get_value<Duration>(tuple, tupdesc, info[5], 0);
    Duration tw_close = get_value<Duration>(tuple, tupdesc, info[6], UINT_MAX);

    if (tw_open > tw_close) {
        throw std::string("Invalid time window found: '") + info[6].name + "' < '" + info[5].name + "'";
    }

    vehicle.tw = ::vroom::TimeWindow(tw_open, tw_close);

    vehicle.speed_factor = get_anynumerical(tuple, tupdesc, info[7], 1.0);
    vehicle.max_tasks = get_value<int32_t>(tuple, tupdesc, info[8], INT_MAX);
    vehicle.data = get_jsonb(tuple, tupdesc, info[9]);

    if (!(column_found(info[1]) || column_found(info[2]))) {
        throw std::string("Missing column(s): '") + info[1].name + "' and/or '" + info[2].name + "' must exist";
    }

    if (vehicle.speed_factor <= 0.0) {
        throw std::string("Invalid negative or zero value in column '") + info[7].name + "'";
    }
    return vehicle;
}


}  // namespace vroom

}   // namespace pgget
}   // namespace pgvroom
