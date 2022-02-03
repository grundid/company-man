import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/employee_list_cubit.dart';
import 'package:provider/provider.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/main.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';

class EmployeeListWidget extends StatelessWidget {
  const EmployeeListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          EmployeeListCubit(Provider.of<SbmContext>(context, listen: false)),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Mitarbeiterliste"),
        ),
        body: BlocBuilder<EmployeeListCubit, EmployeeListState>(
          builder: (context, state) {
            return state is EmployeeListInitialized
                ? ResponsiveListViewElement(
                    child: ListView.builder(
                        itemCount: state.employees.length,
                        itemBuilder: (context, index) {
                          Employee employee = state.employees[index];
                          return ListTile(
                            title: Text(
                                "${employee.person.firstName} ${employee.person.lastName} (${employee.employeeNo})"),
                            onTap: () async {
                              await Routemaster.of(context)
                                  .push(RouteNames.employeeMenu.replaceAll(
                                      ":employeeId", employee.employeeRef!.id))
                                  .result;
                              context.read<EmployeeListCubit>().refresh();
                            },
                          );
                        }),
                  )
                : LoadingAnimationScreen();
          },
        ),
        floatingActionButton: BlocBuilder<EmployeeListCubit, EmployeeListState>(
          builder: (context, state) {
            return FloatingActionButton.extended(
                icon: Icon(Icons.person_add),
                onPressed: () async {
                  await Routemaster.of(context)
                      .push(RouteNames.employeeNew)
                      .result;
                  context.read<EmployeeListCubit>().refresh();
                },
                label: Text("Neuer Mitarbeiter"));
          },
        ),
      ),
    );
  }
}
