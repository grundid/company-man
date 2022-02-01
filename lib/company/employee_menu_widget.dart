import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/employee_menu_cubit.dart';
import 'package:smallbusiness/main.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:provider/provider.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';

class EmployeeMenuWidget extends StatelessWidget {
  final String employeeId;

  const EmployeeMenuWidget({Key? key, required this.employeeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmployeeMenuCubit(
          Provider.of<SbmContext>(context, listen: false), employeeId),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<EmployeeMenuCubit, EmployeeMenuState>(
            builder: (context, state) => state is EmployeeMenuInitialized
                ? Text(
                    "${state.employee.person.firstName} ${state.employee.person.lastName}")
                : Text("..."),
          ),
        ),
        body: BlocBuilder<EmployeeMenuCubit, EmployeeMenuState>(
          builder: (context, state) {
            return state is EmployeeMenuInitialized
                ? ResponsiveBody(
                    addPadding: false,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text("Stammdaten"),
                          onTap: () async {
                            await Routemaster.of(context)
                                .push(RouteNames.employeeEdit +
                                    "?employeeId=${state.employee.employeeRef!.id}")
                                .result;
                            context.read<EmployeeMenuCubit>().refresh();
                          },
                        ),
                        ListTile(
                          title: Text("Benutzer und Berechtigungen"),
                          onTap: () async {
                            Routemaster.of(context).push(RouteNames
                                    .employeeUser +
                                "?employeeId=${state.employee.employeeRef!.id}");
                          },
                        ),
                      ],
                    ),
                  )
                : LoadingAnimationScreen();
          },
        ),
      ),
    );
  }
}
